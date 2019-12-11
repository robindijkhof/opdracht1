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
	// printMethods(|project://smallsql/|);
	countLines(projectLocation);
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




