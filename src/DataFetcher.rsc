module DataFetcher

import util::Resources;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import IO;
import List;
import Map;
import Relation;
import Set;
import String;

import vis::Figure;
import vis::Render;
import vis::KeySym;
import Map;


// Zou methodes ook kunnen opvragen dmv een nieuwe methode met als arugment de loc.
alias Class = tuple[str name,int complexity,int unitsize, loc location, list[Method] methods];
alias Method = tuple[str name, int complexity, int unitsize, loc location];


public list[Class] getData(){
	projectLocation = |project://smallsql/|;

	// get all the java files
	set[loc] bestanden = javaBestanden(projectLocation);
	// create the declarations belonging to these files
	set[Declaration] fileDeclarations = createAstsFromFiles(bestanden, false);
	
	
	
	list[Class] classes = [];
	
	for(D <- fileDeclarations){
		visit (D) {	
			//case \class(name, _, _, body): println(createClass(name, body, first.src));
			case \class(name, _, _, body): classes += <name, getCC(body), getSize(body), D.src, [<"methode1", 5, 20, |project://example-project/src/HelloWorld.java|>]>;  // method without a implementation, cc always is 1 and impl is 0 (no body)
		} 
	}
	
	
	println(classes);
	return classes;
}

// Waarom is CC bij het gebruik van deze methode 0?
Class createClass(str name, list[Declaration] declarations, loc location){
	int size = 0;
	int cc = 1;
	
	for(D <- declarations){
		visit (D) {
			case \method(_, name, para, _):cc += 1;  // method without a implementation, cc always is 1 and impl is 0 (no body)
			case \method(_, name, para, _, impl):cc += calculateCC(impl);  // use the name and the impl
			case \constructor(name, para, _, impl): cc += calculateCC(impl);  // use the name and the impl
		} 
	}	
		
	return <name, cc, size, location, [<"methode1", 5, 20, |project://example-project/src/HelloWorld.java|>]>;
}


int getSize(list[Declaration] declarations){
	int size = 0;
	
	for(D <- declarations){
		visit (D) {
			case \method(_, name, para, _):size += 1;  // method without a implementation, cc always is 1 and impl is 0 (no body)
			case \method(_, name, para, _, impl):size += calculateLOC(impl);  // use the name and the impl
			case \constructor(name, para, _, impl): size += calculateLOC(impl);  // use the name and the impl
		} 
	}	
	return size;
}

int getCC(list[Declaration] declarations){
	int cc = 1;

	for(D <- declarations){
		visit (D) {
			case \method(_, name, para, _):cc += 1;  // method without a implementation, cc always is 1 and impl is 0 (no body)
			case \method(_, name, para, _, impl):cc += calculateCC(impl);  // use the name and the impl
			case \constructor(name, para, _, impl): cc += calculateCC(impl);  // use the name and the impl
		} 
	}	
	return cc;
}

// impl = method
int calculateCC(Statement impl) {
	// always start at 1
    int cc = 1;
    // based on various tokens increase the cc
    visit (impl) {
        case \if(_,_) : cc += 1;
        case \if(_,_,_) : cc += 1;
        case \for(_,_,_) : cc += 1;
        case \for(_,_,_,_) : cc += 1;
        case \catch(_,_): cc += 1;
        case \while(_,_) : cc += 1;
        case \infix(_,"&&",_) : cc += 1;
        case \infix(_,"||",_) : cc += 1;
        case \foreach(_,_,_) : cc += 1;
        case \case(_) : cc += 1;
        case \do(_,_) : cc += 1;
        case \conditional(_,_,_) : cc += 1;
    }
    return cc;
}

public set[loc] javaBestanden(loc project) {
	Resource r = getProject(project);
	// /file(a) = list comprehension = zoek deep match somewhere in the data
	return { a | /file(a) <- r, a.extension == "java" };
}

public set[loc] javaBestanden(Resource project) {
   return { a | /file(a) <- project, a.extension == "java" };
}

int calculateLOC(loc location) {
	return size(readFilterdLines(location));
}

public list[str] readFilterdLines(loc location){
	return [ trim(line) | str line <- readFileLines(location), filterLine(line)];
}


public bool filterLine(str line){	
	line = trim(line);
	
	bool isJavaLine =  !(
		/^(\}|\)|;)+$/ := line || //check for occurrences of }, ), })}, };)}, etc
		/^(\{|\))+$/ := line || // also check for occurrences of (for example): {{, {(, {(
		/^$/ := line || // check for empty lines
		/^(import|package|\/\/)/ := line || // check for starts with import, package, //
		/^(\*\/|\*|\/\*)/ := line // check for starts with *, */, /*
	);
	
	return isJavaLine;
}

int calculateLOC(Statement impl) {
	return size(readFilterdLines(impl.src));
}
