module Opdracht1


import util::Resources;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import IO;
import List;
import Map;
import Relation;
import Set;
import String;

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


public void unitSize(){
	M3 model = createM3FromEclipseProject(|project://smallsql/src/smallsql/database|);
   	methoden =  { <x,y> | <x,y> <- model.containment
                       , (x.scheme=="java+class" && startsWith(x.path, "/smallsql/database"))
                       , y.scheme=="java+method" || y.scheme=="java+constructor" 
                       };
                       
    methodSize = { getMethodSize(<x,y>) | <x,y> <- methoden};
    
    int simple = 0;
    int average = 0;
    int complex = 0;
    int untestable = 0;
    
    for (<a,n> <- sort(methodSize, bool(tuple[&a, num] x, tuple[&a, num] y){ return x[1] > y[1]; })){
	    if(n < 11){
	    	simple += 1;
	    }
	    else if(n < 21){
	    	average += 1;
	    }
	    else if(n < 51){
	    	complex += 1;
	    }
	    else{
	    	untestable += 1;
	    }
    	//println("<a>: unitsize: <n>");
    }
    
    int total = simple + average + complex + untestable;
    println("simple: <simple>");
    println("average: <average>");
    println("complex: <complex>");
    println("untestable: <untestable>");   
    println("total: <total>");
    
    println("simple%: <simple * 1.0/total*100>");
    println("average%: <average * 1.0/total*100>");
    println("complex%: <complex * 1.0/total*100>");
    println("untestable%: <untestable * 1.0/total*100>"); 
    
}


public void cyclomaticComplexity(){
	projectLocation = |project://smallsql/|;
	//projectLocation = |project://JabberPoint/|;


	// get all the java files
	set[loc] bestanden = javaBestanden(projectLocation);
	// create the declarations belonging to these files
	set[Declaration] fileDeclarations = createAstsFromFiles(bestanden, false);
	
	rel[str, int, int] totalResult = {}; // loc+func+param, cc, LOC
	
	// cycle through all the declarations
	// use http://tutor.rascal-mpl.org/Rascal/Libraries/lang/java/m3/AST/Declaration/Declaration.html to see how declarations is build
	// note: Always store <fileLoc+methodName+parameters,cc> to make sure each entry is unique! (previous when we stored: <name, cc> and a function was added twice with the same cc, only 1 would be added)
	for(D <- fileDeclarations){
		visit (D) {
			
			case \method(_, name, para, _):totalResult +=    		<"fileLoc:<D.src> method: <name>(<para>)", 1, 0>;  // method without a implementation, cc always is 1 and impl is 0 (no body)
			case \method(_, name, para, _, impl):totalResult +=    	<"fileLoc:<D.src> method: <name>(<para>)", calculateCC(impl), calculateLOC(impl)>;  // use the name and the impl
			case \constructor(name, para, _, impl): totalResult += 	<"fileLoc:<D.src> method: <name>(<para>)", calculateCC(impl), calculateLOC(impl)>;  // use the name and the impl
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
	
	num lowLines = 0;
	num moderateLines = 0;
	num highLines = 0;
	num veryHighLines = 0;
	
	
	
	// a: functionName, b: CC
	for(<a,b,c> <- totalResult){
		if(b>50){
			veryHigh += 1;
			veryHighLines += c;
		}else if(b >= 21){
			high += 1;
			highLines += c;
		}else if(b >= 11){
			moderate += 1;
			moderateLines += c;
		}else{
			low += 1;
			lowLines += c;
		}
	}
	num totalLines = lowLines + moderateLines + highLines + veryHighLines;

	// print results
	println("Cyclomatic Complexity Risk Calculation");
	println("Project <projectLocation>");
	println("Total methods: <totalMethods>");
	println("Total lines: <totalLines>");
	println("---------------------------------------");
	println("Very high: functions: <veryHigh> (<veryHigh / totalMethods * 100>%) LOC: <veryHighLines> (<veryHighLines / totalLines * 100>%)");
	println("High: functions: <high> (<high / totalMethods * 100>%) LOC: <highLines> (<highLines / totalLines * 100>%)");
	println("Moderate: functions: <moderate> (<moderate / totalMethods * 100>%) LOC: <moderateLines> (<moderateLines / totalLines * 100>%)");
	println("Low: functions: <low> (<low / totalMethods * 100>%) LOC: <lowLines> (<lowLines / totalLines * 100>%)");
	println("---------------------------------------");
}

public void duplication(){
	int blockSize = 6;
	list[str] duplicates = [];
	set[str] duplicatesUniek = {};
	int dup = 0;

	Resource smallsql = getProject(|project://smallsql/src/smallsql/database|);
	list[loc] bestanden = toList(javaBestanden(smallsql));

	list[list[str]] filesAndCode = [ readFilterdLines(a) | a <- bestanden];
	
	notFound = true;
	
	int fileIndex = 0;
	while(fileIndex < size(filesAndCode)){
		list[str] fileCode = filesAndCode[fileIndex];
		
		int lineIndex = 0;
		while(lineIndex < (size(fileCode) - blockSize)){
			//block maken
			str lines = "";
			int blockIndex = lineIndex;
			while(blockIndex < lineIndex + blockSize){
				lines = lines + fileCode[blockIndex];
				blockIndex += 1;
			}
	
		
			int comparingFileIndex = fileIndex;
			while(comparingFileIndex < size(filesAndCode) && notFound){
				list[str] comparingFileCode = filesAndCode[comparingFileIndex];
			
				if(lineIndex < (size(fileCode) - 1 - blockSize)){ // Niet tegen zichtzelf bekijken
					int comparingLineIndex = lineIndex + 1;
					while(comparingLineIndex < (size(comparingFileCode)-blockSize)  && notFound){
						//Block om te vergelijken maken.
						str comparingLines = "";
						int comparingBlockIndex = comparingLineIndex;
						while(comparingBlockIndex < comparingLineIndex + blockSize){
							comparingLines = comparingLines + comparingFileCode[comparingBlockIndex];
							comparingBlockIndex += 1;
						}
						
						
						if(lines == comparingLines){
						
							//De gevonden lines individueel toevoegen aan de list en set.
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
	println("Aantal unieke duplication regels: <size(duplicatesUniek)>");
	
	
	
	
}


// ---------------------------------------- Helper functions -------------------------------------------
int calculateLOC(Statement impl) {
	return size(readFilterdLines(impl.src));
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


public tuple[loc a, int b] getMethodSize(tuple[loc a, loc b] method){
    	return <method.b, size(readFilterdLines(method.b))>;
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


// Alternative, not used right now!
public bool filterLineStringCompare(str line){	
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

public set[loc] javaBestanden(loc project) {
	Resource r = getProject(project);
	// /file(a) = list comprehension = zoek deep match somewhere in the data
	return { a | /file(a) <- r, a.extension == "java" };
}

public set[loc] javaBestanden(Resource project) {
   return { a | /file(a) <- project, a.extension == "java" };
}

public bool aflopend(tuple[&a, num] x, tuple[&a, num] y) {
	return x[1] > y[1];
}