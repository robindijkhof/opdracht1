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
import util::Resources;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import IO;
import List;
import Map;
import Relation;
import Set;
import String;


public void run() {
	//projectLocation = |project://smallsql/|;
	//projectLocation = |project://JabberPoint/|;
	
	
	
	// printMethods(|project://smallsql/|);
	//countLines(projectLocation);
	//cyclomaticComplexity();
	//linesOfCode();
	duplication2();
}

public void duplication2(){
	int blockSize = 6;
	list[str] duplicates = [];
	set[str] duplicatesUniek = {};
	int dup = 0;

	Resource smallsql = getProject(|project://JabberPoint/|);
	list[loc] bestanden = toList(javaBestanden(smallsql));

	// list with all files and in them all lines
	list[list[str]] filesAndCode = [ readFilterdLines(a) | a <- bestanden];
	
	notFound = true;
	
	//loop through each file
	int fileIndex = 0;
	while(fileIndex < size(filesAndCode)){
	
		// get list with all LOC
		list[str] fileCode = filesAndCode[fileIndex];
		
		// loop through all lines excl the last blockSize (6)
		int lineIndex = 0;
		while(lineIndex < (size(fileCode) - blockSize)){
			//block maken
			str lines = "";
			int blockIndex = lineIndex;
			while(blockIndex < lineIndex + blockSize){
				lines = lines + fileCode[blockIndex];
				blockIndex += 1;
			}
			//lines =  long string with 6 lines of strings in it
		
			//loop through all remaining files
			int comparingFileIndex = fileIndex;
			while(comparingFileIndex < size(filesAndCode) && notFound){ // loop through the files
				list[str] comparingFileCode = filesAndCode[comparingFileIndex]; // current file to check
			
				if(lineIndex < (size(fileCode) - 1 - blockSize)){ // Niet tegen zichtzelf bekijken
					int comparingLineIndex = lineIndex + 1;
					while(comparingLineIndex < (size(comparingFileCode)-blockSize)  && notFound){
						str comparingLines = "";
						int comparingBlockIndex = comparingLineIndex;
						while(comparingBlockIndex < comparingLineIndex + blockSize){
							comparingLines = comparingLines + comparingFileCode[comparingBlockIndex];
							comparingBlockIndex += 1;
						}
						
						
						if(lines == comparingLines){
						
							comparingBlockIndex = comparingLineIndex;
							while(comparingBlockIndex < comparingLineIndex + blockSize){
								duplicates = duplicates + comparingFileCode[comparingBlockIndex];
								duplicatesUniek = duplicatesUniek + comparingFileCode[comparingBlockIndex];
								comparingBlockIndex += 1;
							}
						
						
							//duplicates = duplicates + lines;
							dup = dup + 1;	
							//println("dupplicate: <line>");
							notFound = false;
						}	
					
						comparingLineIndex = comparingLineIndex + 1;
					}
				}
		
		
		
				comparingFileIndex = comparingFileIndex + 1;
			}
			
			notFound = true;
			
		
			lineIndex = lineIndex + 1;
		}
	
		fileIndex = fileIndex + 1;
	}
	

	println("Aantal Duplication: <dup>");
	println("Aantal duplication regels: <size(duplicates)>");
	println("Aantal unieke duplication regels: <size(duplicates)>");
	
	
	
	
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


public set[loc] javaBestanden(Resource project) {
   return { a | /file(a) <- project, a.extension == "java" };
}


public set[loc] javaBestanden(loc project) {
	Resource r = getProject(project);
	// /file(a) = list comprehension = zoek deep match somewhere in the data
	return { a | /file(a) <- r, a.extension == "java" };
}



public void cyclomaticComplexity(){
	projectLocation = |project://smallsql/|;
	//projectLocation = |project://JabberPoint/|;


	// get all the java files
	set[loc] bestanden = javaBestanden(projectLocation);
	// create the declarations belonging to these files
	set[Declaration] fileDeclarations = createAstsFromFiles(bestanden, false);
	
	rel[str, int] totalResult = {};
	

	// cycle through all the declarations
	// use http://tutor.rascal-mpl.org/Rascal/Libraries/lang/java/m3/AST/Declaration/Declaration.html to see how declarations is build
	// note: Always store <fileLoc+methodName+parameters,cc> to make sure each entry is unique! (previous when we stored: <name, cc> and a function was added twice with the same cc, only 1 would be added)
	for(D <- fileDeclarations){
		visit (D) {
			case \method(_, name, para, _):totalResult +=    <"fileLoc:<D.src> method: <name>(<para>)", 1>;  // method without a implementation, cc always is 1
			case \method(_, name, para, _, impl):totalResult +=    <"fileLoc:<D.src> method: <name>(<para>)", calculateCC(impl)>;  // use the name and the impl
			case \constructor(name, para, _, impl): totalResult += <"fileLoc:<D.src> method: <name>(<para>)", calculateCC(impl)>;  // use the name and the impl
		} 
	}

	//Uncomment to see all methods and their CC
	/*
	for(<a,b> <- sort(toList(totalResult), aflopend)){
		println("<a> CC: <b>"); //negeer de IDE error, print de waarde in a.file en b
	}*/
	
	//calculate risk evalution
	num low = 0;
	num moderate = 0;
	num high = 0;
	num veryHigh = 0;
	num totalMethods = size(totalResult);
	
	
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
	println("Total methods: <totalMethods>");
	println("---------------------------------------");
	println("Very high: <veryHigh> (<veryHigh / totalMethods * 100>%)");
	println("High: <high> (<high / totalMethods * 100>%)");
	println("Moderate: <moderate> (<moderate / totalMethods * 100>%)");
	println("Low: <low> (<low / totalMethods * 100>%)");
	println("---------------------------------------");
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


// ----------------------------------- LOC -----------------------------------
public void linesOfCode(){
	Resource smallsql = getProject(|project://smallsql/src/smallsql/database|);
	set[loc] bestanden = javaBestanden(smallsql);

	//Aantal regels per file.
	map[loc, int] regels = ( a:size(readFilterdLines(a)) | a <- bestanden);
	
   	//for (<a, b> <- sort(toList(regels), bool(tuple[&a, num] x, tuple[&a, num] y){ return x[1] > y[1]; }))
    //  println("<a.file>: <b> regels");  
      
    //Reducer om de regels bij elkaar op te tellen
    int lines = reducer(range(regels), int(int a,int b){return a + b;}, 0);
      
    println("Total lines of java code: <lines> ");
}

public list[str] readFilterdLines(loc location){
	return [ line | str line <- readFileLines(location), filterLine(line)];
}

public bool filterLine(str line){	
	line = trim(line);
	bool isJavaLine =  !(
		line == "{" ||
		line == "}" ||
		line == "});" ||
		line == ";" ||
		line == "}});" ||
		line == "})});" ||
		line == "" ||
		line == "" ||
		startsWith(line, "import") ||
		startsWith(line, "package") ||
		startsWith(line, "//") ||
		startsWith(line, "*/") ||
		startsWith(line, "*") ||
		startsWith(line, "/*")
	);
	
	return isJavaLine;
}




//==================================================== OLD =================================================================

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
				case \if(_,_) : cc += 1;
		        case \if(_,_,_) : cc += 1;
		        case \for(_,_,_) : cc += 1;
		        case \for(_,_,_,_) : cc += 1;
		        case \catch(_,_): cc += 1;
		        case \while(_,_) : cc += 1;
		        case infix(_,"&&",_) : cc += 1;
		        case infix(_,"||",_) : cc += 1;
		        case \foreach(_,_,_) : cc += 1;
		        case \case(_) : cc += 1;
		        case \do(_,_) : cc += 1;
			}
			result += ( D.src : cc);
		}
		count += 1;	
	}
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



