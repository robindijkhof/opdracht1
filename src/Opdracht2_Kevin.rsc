module Opdracht2_Kevin

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

public void run(){
	println("Hello");
	list[Class] infodata = getData();
	
	renderProjectView(infodata);
}

public list[Class] getData(){
	list[Class] infodata = [
		<"Eerste klasse", 30, 120, |project://example-project/src/HelloWorld.java|, [<"methode1", 5, 20, |project://example-project/src/HelloWorld.java|>]>,
		<"Tweede klasse", 50, 30, |project://example-project/src/HelloWorld.java|, [<"methode1", 5, 20, |project://example-project/src/HelloWorld.java|>]>
	];
	return infodata;
}



void renderProjectView(list[Class] projectData){
	Figure redBox = box(size(40), fillColor("red"));
	list[Figure] classFigures = [];
	
	for(Class class <- projectData) {
		// Figure nwClassFigure = createClassBox(class);
		classFigures += createClassBox(class);
	}

	render("ProjectView", hcat(classFigures));
}

Figure createClassBox(Class class){
	return createBox(class.complexity, class.unitsize);
}


// ==================================================== Helper functions ===========================================================
Figure createBox(int width, int height){
	Figure redBox = box(size(width, height), fillColor("red"), resizable(false));
	return redBox;
}


// helper function: The helper function copy copies an element a number of times: for example, copy(3,"a") results in list[str]: ["a","a","a"]. 
list[&T] copy(int n, &T element) {
	return [ element | _ <- [0..n] ];
}


