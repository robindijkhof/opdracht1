module Opdracht2

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
import DataFetcher;
import util::ValueUI;
import util::Math;

// Zou methodes ook kunnen opvragen dmv een nieuwe methode met als arugment de loc.
alias Class = tuple[str name,int complexity,int unitsize, loc location, list[Method] methods];
alias Method = tuple[str name, int complexity, int unitsize, loc location];

public void run(){
	println("Hello");
	list[Class] infodata = getData();
	renderProjectView(infodata);
}



void renderProjectView(list[Class] projectData){
	list[Figure] classFigures = [];
	for(Class class <- projectData) {
		classFigures += createClassBox(class);
	}

	render("ProjectView", treemap(classFigures));
}

Figure createClassBox(Class class){
	real complexityPerc = class.complexity / 50.0; // calc the relative complexity percentage based on max allowed
	real sizePerc = class.unitsize / 300.0; // calc the relative size percentage based on max allowed
	
	real complexityPoints = complexityPerc * 100.0; // assign (penalty) points
	real sizePoints = sizePerc * 100.0; // assign (penalty) points
	
	int boxSize = toInt(complexityPoints) + toInt(sizePoints); // calc the total (penalty) points for this method
	
	Color color = generateColor(complexityPerc); // generate a color between green -> red based on the complexity rating
	Figure figure = box(text(class.name),area(boxSize), fillColor(color)); // create the figure
	
	return figure;
}


Color generateColor(real percentage){
	int redColor = toInt(255.0 * percentage); // assign red color based on percentage
	int greenColor = 255 - redColor; // fill the rest with green
	return rgb(redColor, greenColor, 0);
}


list[Class] getDummyData(){
	return [
		<"Klasse1", 9, 400, |project://smallsql/src/smallsql/database|, [<"Methode1_1", 4, 20, |project://smallsql/src/smallsql/database|>, <"Methode1_2", 14, 210, |project://smallsql/src/smallsql/database|>, <"Methode1_3", 16, 78, |project://smallsql/src/smallsql/database|>]>,
		<"Klasse2", 6, 100, |project://smallsql/src/smallsql/database|, [<"Methode2_1", 6, 100, |project://smallsql/src/smallsql/database|>]>,
		<"Klasse3", 2, 50, |project://smallsql/src/smallsql/database|, [<"Methode3_1", 12, 50, |project://smallsql/src/smallsql/database|>]>,
		<"Klasse4", 12, 75, |project://smallsql/src/smallsql/database|, [<"Methode4_1", 12, 50, |project://smallsql/src/smallsql/database|>]>,
		<"Klasse5", 22, 48, |project://smallsql/src/smallsql/database|, [<"Methode8=5_1", 12, 50, |project://smallsql/src/smallsql/database|>]>,
		<"Klasse6", 11, 68, |project://smallsql/src/smallsql/database|, [<"Methode6_1", 12, 50, |project://smallsql/src/smallsql/database|>]>,
		<"Klasse7", 9, 26, |project://smallsql/src/smallsql/database|, [<"Methode7_1", 12, 50, |project://smallsql/src/smallsql/database|>]>,
		<"Klasse8", 12, 77, |project://smallsql/src/smallsql/database|, [<"Methode8_1", 14, 400, |project://smallsql/src/smallsql/database|>]>
	];
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