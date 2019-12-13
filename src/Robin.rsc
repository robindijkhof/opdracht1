module Robin

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
	Resource smallsql = getProject(|project://hsqldb/src|);
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

	Resource smallsql = getProject(|project://JabberPoint|);
	list[loc] bestanden = toList(javaBestanden(smallsql));

	list[list[str]] filesAndCode = [ readFilterdLines(a) | a <- bestanden];
	
	notFound = true;
	
	int fileIndex = 0;
	while(fileIndex < size(filesAndCode)){
		list[str] fileCode = filesAndCode[fileIndex];
		
		int lineIndex = 0;
		while(lineIndex < size(fileCode)){
			str line = fileCode[lineIndex];
		
			int comparingFileIndex = fileIndex;
			while(comparingFileIndex < size(filesAndCode) && notFound){
				list[str] comparingFileCode = filesAndCode[comparingFileIndex];
			
				if(lineIndex < size(fileCode) - 1){ // Niet tegen zichtzelf bekijken
					int comparingLineIndex = lineIndex + 1;
					while(comparingLineIndex < size(comparingFileCode)  && notFound){
						str comparingLine = comparingFileCode[comparingLineIndex];
						
						if(line == comparingLine){
							duplicates = duplicates + line;
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
	

	println("Duplication: <dup>");
	println("Unieke duplication: <size(duplicates)>");
	
	
	
}



public void duplication2(){
	int blockSize = 6;
	list[str] duplicates = [];
	set[str] duplicatesUniek = {};
	int dup = 0;

	Resource smallsql = getProject(|project://JabberPoint|);
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
	println("Aantal unieke duplication regels: <size(duplicatesUniek)>");
	
	
	
	
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

public tuple[loc a, int b] getMethodSize(tuple[loc a, loc b] method){
    	return <method.b, size(readFilterdLines(method.b))>;
}
   


public list[str] readFilterdLines(loc location){
	return [ trim(line) | str line <- readFileLines(location), filterLine(line)];
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

