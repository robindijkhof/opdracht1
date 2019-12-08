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

public void unitComplexity(){




	M3 model = createM3FromEclipseProject(|project://smallsql/src/smallsql/database|);
	
	
   	methoden =  { <x,y> | <x,y> <- model.containment
                       , x.scheme=="java+class"
                       , y.scheme=="java+method" || y.scheme=="java+constructor" 
                       };
                       
   //test = range(methoden);
   
   //println(test);
                       
                       int aantal = 0;
                       
    for(tuple[loc a, loc b] method <- methoden) {
    	println(method.a);      
    	println(readFile(method.b));
    	Declaration dec = createAstFromString(method.b, readFile(method.b), true);
    	println(dec);
    	
    	
    	
    	aantal = aantal +1;
    	
    	if(aantal == 1){
    		return;
    	}
    }
                 
                       
    //telMethoden = { <a, size(methoden[a])> | a <- domain(methoden) };
   	//for (<a,n> <- sort(telMethoden, bool(tuple[&a, num] x, tuple[&a, num] y){ return x[1] > y[1]; }))
    // 	println("<a>: <n> methoden");
}

public void duplication(){
	set[str] duplicates = {};
	int dup = 0;

	Resource smallsql = getProject(|project://                                                                             |);
	list[loc] bestanden = toList(javaBestanden(smallsql));

	list[list[str]] filesAndCode = [ readFilterdLines(a) | a <- bestanden];
	
	notFound = true;
	
	int i = 0;
	while(i < size(filesAndCode)){
		list[str] fileCode = filesAndCode[i];
		
		int j = 0;
		while(j < size(fileCode)){
			str line = fileCode[j];
		
			int x = i;
			while(x < size(filesAndCode) && notFound){
				list[str] comparingFileCode = filesAndCode[x];
			
				if(j < size(fileCode) - 1){ // Niet tegen zichtzelf bekijken
					int y = j + 1;
					while(y < size(comparingFileCode)  && notFound){
						str comparingLine = comparingFileCode[y];
						
						if(line == comparingLine){
							duplicates = duplicates + line;
							dup = dup + 1;	
							//println("dupplicate: <line>");
							notFound = false;
						}	
					
						y = y + 1;
					}
				}
		
		
		
				x = x + 1;
			}
			
			notFound = true;
			
		
		
		
			j = j + 1;
		}
	
	//	list[str] lines = filesAndCode[range(filesAndCode)[i]];
	//	//println(index(range(filesAndCode))[0]);
	//
	//
	//
	//
		i = i + 1;
	}
	

	println("Duplication: <dup>");
	println("Unieke duplication: <size(duplicates)>");
	
	
	
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


