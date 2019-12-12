module Kevin

import IO;
import util::Resources;
import List;
import Map;
import Relation;
import Set;
import analysis::graphs::Graph;
import util::Resources;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import analysis::m3::AST;


public void run() {
	projectLocation = |project://smallsql/|;
	//projectLocation = |project://JabberPoint/|;
	
	
	
	// printMethods(|project://smallsql/|);
	//countLines(projectLocation);
	cyclomaticComplexity();
}


public bool aflopend(tuple[&a, num] x, tuple[&a, num] y) {
	return x[1] > y[1];
}

public bool aflopend(tuple[&a, num] x, tuple[&a, num] y) {
	return x[1] > y[1];
}



public void printMethods(loc project) {
	 M3 model = createM3FromEclipseProject(project);
	 for (loc l <- methods(model)) {
	 	str s = readFile(l);
	 	println("=== <l> ===\n<s>");
	}
}

private void countLines(loc project) {
	// M3 model = createM3FromEclipseProject(project);
	Resource resources =  getProject(project);
	set[loc] bestanden = {a | /file(a) <- resources, a.extension == "java"}; // maak een set[loc] van alle bestanden in r waar de extension java is
	
	// the result that maps the loc to the LOCs
	map[loc, int] result = ();
	int totalLines = 0;
	
	for(loc bestand <- bestanden) {
		if(bestand.file == "StorePageLink.java" || true){ //test on StorePageLink.java
			//get all the lines in a file
			list[str] lines = readFileLines(bestand);
			
			//find all lines that match the 'Not LOC'
			//first or: match on lines that start with (white characters)* and then a / or *
			//second or: match on lines only contains (white characters)*
			//third or: match on lines starts with (white characters)* then a { or } and then (white characters)* until the end of line 
			list[str] emptyLines = [N | str N <- lines, /(^\s*(\/|\*))|(^\s*$)|(^\s*(\{|\})\s*$)/ := N];
			
			//find the LOC by subtracting the totalNr-emptyLines
			int nrOfLines = size(lines) - size(emptyLines);
			
			//add the new mapping to the result map
			result += ( bestand : nrOfLines);
			totalLines += nrOfLines;
		}
	}
	
	// print the result in a ordened list
	for(<a,b> <- sort(toList(result), aflopend)){
		println("<a.file>: <b> regels"); //negeer de IDE error, print de waarde in a.file en b
	}
	println("Totaal aantal regels: <totalLines>");
}


private void countLinesSimple(loc project) {
	// M3 model = createM3FromEclipseProject(project);
	Resource resources =  getProject(project);
	set[loc] bestanden = {a | /file(a) <- resources, a.extension == "java"}; // maak een set[loc] van alle bestanden in r waar de extension java is
	
	map[loc, int] regels = (a:size(readFileLines(a)) | a <- bestanden);
	lrel[loc, int] regelsInList = toList(regels);
	
	for(<a,b> <- sort(regelsInList, aflopend)){
		println("<a.file>: <b> regels"); //negeer de IDE error, print de waarde in a.file en b
	}
}


public set[loc] javaBestanden(loc project) {
	Resource r = getProject(project);
	// /file(a) = list comprehension = zoek deep match somewhere in the data
	return { a | /file(a) <- r, a.extension == "java" };
}

public lrel[str, Statement] methodenAST(loc project) {
	set[loc] bestanden = javaBestanden(project);
	// maak set met hierin de AbstractSyntaxTrees(?) van elk bestand
	

	set[Declaration] decls = createAstsFromFiles(bestanden, false);
	lrel[str, Statement] result = [];
	// loop over de set met hierin AST's heen en vind alle methoden en constructors, deze worden aan de result toegevoegd
	// result is lrel[str, statement] <methodeName, aantal implementaties hiervan>
	visit (decls) {
		case \method(_, name, _, _, impl): result += <name, impl>;
		case \constructor(name, _, _, impl): result += <name, impl>;
	}
	return(result);
}


private void cyclomaticComplexity(){
	projectLocation = |project://smallsql/|;
	//projectLocation = |project://JabberPoint/|;


	// get all the java files
	set[loc] bestanden = javaBestanden(projectLocation);
	// create the declarations belonging to these files
	set[Declaration] fileDeclarations = createAstsFromFiles(bestanden, false);
	
	rel[str, int] totalResult = {};
	
	// cycle through all the declarations
	// use http://tutor.rascal-mpl.org/Rascal/Libraries/lang/java/m3/AST/Declaration/Declaration.html to see how declarations is build
	for(D <- fileDeclarations){
		visit (D) {
			case \method(_, name, _, _, impl):totalResult += <name, calculateCC(impl)>; // use the name and the impl
			case \constructor(name, _, _, impl): totalResult += <name, calculateCC(impl)>; // use the name and the impl
		} 
	}
	
	//Uncomment to see all methods and their CC
	/*
	for(<a,b> <- sort(toList(totalResult), aflopend)){
		println("<a> CC: <b>"); //negeer de IDE error, print de waarde in a.file en b
	}*/
	
	//calculate risk evalution
	int low = 0;
	int moderate = 0;
	int high = 0;
	int veryHigh = 0;
	
	
	// a: functionName, b: CC
	for(<a,b> <- sort(toList(totalResult), aflopend)){
		if(b>50){
			veryHigh += 1;
		}else if(b >= 21){
			high += 1;
		}else if(b >= 11){
			moderate += 1;
		}else{
			low += 1;
		}
	}
	
	// print results
	println("Cyclomatic Complexity Risk Calculation");
	println("Project <projectLocation>");
	println("---------------------------------------");
	println("Very high: <veryHigh>");
	println("High: <high>");
	println("Moderate: <moderate>");
	println("Low: <low>");
	println("---------------------------------------");
}


private void cyclomaticComplexity2(projectLocation){
	//M3 model = createM3FromEclipseProject(projectLocation);
	//println(calcCC(model));
	//println(methodenAST(projectLocation));
	//M3 model = createM3FromEclipseProject(projectLocation);
	// methoden = { <x,y> | <x,y> <- model.containment, x.scheme=="java+class", y.scheme=="java+method" ||y.scheme=="java+constructor"};
	
	/*
	for(<a,b> <- model.containment, b.scheme=="java+method" || b.scheme=="java+constructor"){
		println("<a> methodOverrides <b>");
		createAst
	}*/
	set[loc] bestanden = javaBestanden(projectLocation);
	set[Declaration] decls = createAstsFromFiles(bestanden, false);
	
	
	
	
	map[loc, int] result = ();
	println("reset");
	
	int count = 0;
	
	for(D <- decls){
		if(count == 12){
			// println(D.class);
		
			
			int cc = 1;
			//println(D); //negeer de IDE error, print de waarde in a.file en b
			visit (D) {
				case \method(_,_,_,_,impl) : println(calcCC(impl));
		        case \if(_,_,_) : cc += 1;
		        case \case(_) : cc += 1;
		        case \do(_,_) : cc += 1;
		        case \while(_,_) : cc += 1;
		        case \for(_,_,_) : cc += 1;
		        case \for(_,_,_,_) : cc += 1;
		        case foreach(_,_,_) : cc += 1;
		        case \catch(_,_): cc += 1;
		        case \conditional(_,_,_): cc += 1;
		        case infix(_,"&&",_) : cc += 1;
		        case infix(_,"||",_) : cc += 1;
			}
			result += ( D.src : cc);
		}
		count += 1;
		
	}
	//print result:
	/*
	for(<a,b> <- sort(toList(result), aflopend)){
		println("<a>: <b> cc"); //negeer de IDE error, print de waarde in a.file en b
	}*/
	
	
	
	
	//println(result);
	/*
	bool first = true;
	for(<a,b> <- methoden) {
		if(first){
			list[str] nwLines = readFileLines(b);
			Declaration dec = createAstFromString(method.b, readFile(method.b), true);
			println(dec);
			
		}
		first = false;
	}*/
	
	
	
	
	
	/*
	for(<a,b> <- methoden) {
		println("<a> : <b>");
		calcCC(a);
	}*/
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
        case infix(_,"&&",_) : cc += 1;
        case infix(_,"||",_) : cc += 1;
        case foreach(_,_,_) : cc += 1;
        case \conditional(_,_,_): cc += 1;
        case \case(_) : cc += 1;
        case \do(_,_) : cc += 1;
    }
    return cc;
}


