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

	map[loc, int] regels = ( a:size(readFilterdLines(a)) | a <- bestanden);
	
   	//for (<a, b> <- sort(toList(regels), bool(tuple[&a, num] x, tuple[&a, num] y){ return x[1] > y[1]; }))
    //  println("<a.file>: <b> regels");  
      
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
    
    for (<a,n> <- sort(methodSize, bool(tuple[&a, num] x, tuple[&a, num] y){ return x[1] > y[1]; }))
     	println("<a>: unitsize: <n>");
    
}


// ---------------------------------------- Helper functions -------------------------------------------
public tuple[loc a, int b] getMethodSize(tuple[loc a, loc b] method){
    	return <method.b, size(readFilterdLines(method.b))>;
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


public set[loc] javaBestanden(Resource project) {
   return { a | /file(a) <- project, a.extension == "java" };
}