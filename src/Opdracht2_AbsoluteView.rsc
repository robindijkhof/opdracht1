module Opdracht2_AbsoluteView

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


num NORM_UNITSIZE = 6;

// SORTMODE
int SORTMODE_COMPLEXITY = 1;
int SORTMODE_UNITSIZE = 2; 

int sortmode = 2;

// Zou methodes ook kunnen opvragen dmv een nieuwe methode met als arugment de loc.
alias Class = tuple[str name,int complexity,int unitsize, loc location, list[Method] methods];
alias Method = tuple[str name, int complexity, int unitsize, loc location];


list[Class] projectData;

Figure menu;

bool complexityEnabled = true;
bool unitSizeEnabled = true;

int sortMode = 2;

Class classSelected;
bool inClassMode = false;

public void run(){
	//projectData = getDummyData(); //test with dummy data
	projectData = getData(); // test with real data

   	createMenu();

	refresh();
}



// this function can always be called and will render de view based on selected data
void refresh(){
	if(inClassMode){ // if a class is selected then render this class
		renderClassView(classSelected);
		return;
	}
	
	//if no class is selected, render the project overview
	renderProjectView(projectData);
}

// ---------------------------------------------------- RENDERS ----------------------------------------------------------------
void renderProjectView(list[Class] projectDataUnsorted){
	list[Class] projectData = projectDataUnsorted;
	
	//based on sortMode set the order of the projectData
	if(sortmode == SORTMODE_COMPLEXITY){
		projectData = sort(projectDataUnsorted, sortComplexity);
	}else if (sortmode == SORTMODE_UNITSIZE){
		projectData = sort(projectDataUnsorted, sortUnitsize);
	}
	
	
	list[Figure] classFigures = [];
	
	for(Class class <- projectData) {
		classFigures += createClassBox(class); //create a box for each class
	}

	finalRender(classFigures);
}


void renderClassView(Class class){
	list[Method] methodList = class.methods;

	//based on sortMode set the order of the methodList
	if(sortmode == SORTMODE_COMPLEXITY){
		methodList = sort(class.methods, sortComplexity);
	}else if (sortmode == SORTMODE_UNITSIZE){
		methodList = sort(class.methods, sortUnitsize);
	}

	// set the data for classMode
	inClassMode = true;
	classSelected = class;

	list[Figure] methodFigures = [];
	for(Method method <- methodList) {
		methodFigures += createMethodBox(method); //create a list with a box for each method
	}

	finalRender(methodFigures); //render the methodFigures
}


void finalRender(list[Figure] figures){
	Figure boxes = hcat(figures);
	render("ProjectView", vcat([menu, scrollable(boxes)])); //combine all the figures in a single figure and render it
}



// ==================================================== BOXES ======================================================================
Figure createClassBox(Class class){
	bool event_openMethod(int butnr, map[KeyModifier,bool] modifiers) {
		renderClassView(class);
		return true;
	};
	
	// assign a color based on the penatly points
	real penaltyPoints = toReal(calcPenaltyPoints(class.complexity, class.unitsize));
	real penaltyPerc = penaltyPoints / 200.0;
	Color color = generateColor(penaltyPerc);
	
	Figure boxSized = box( createBoxSize(class.complexity, class.unitsize), fillColor(color), onMouseDown(event_openMethod), hresizable(false), vresizable(false)); // create the figure
	Figure figure = overlay([boxSized, text(class.name, align(0.5,0.6) )]);
	
	return figure;
}


Figure createMethodBox(Method method){
	bool event_showCode(int butnr, map[KeyModifier,bool] modifiers) {
		return true;
	}
	
	// assign a color based on the penatly points
	real penaltyPoints = toReal(calcPenaltyPoints(method.complexity, method.unitsize));
	real penaltyPerc = penaltyPoints / 200.0;
	Color color = generateColor(penaltyPerc);

	Figure boxSized = box( createBoxSize(method.complexity, method.unitsize), onMouseDown(event_showCode), fillColor(color),  hresizable(false), vresizable(false)); // create the figure
	Figure figure = overlay([boxSized, text(method.name, align(0.5,0.6) )]);
	
	return figure;
}



// ==================================================== Helper functions ===========================================================

void createMenu(){
	Figure complexityButton = button("Complexity", void(){sortmode = SORTMODE_COMPLEXITY; refresh();});
   	Figure unitSizeButton = button("UnitSize", void(){sortmode = SORTMODE_UNITSIZE; refresh();});
   	Figure returnButton = button("Return", void(){inClassMode = false;refresh();});
	menu = hcat([complexityButton, unitSizeButton, returnButton], vshrink(0.05));
}

//allow the user to see the code of a method
public void openCode(Method method) {
   render(method.name, text(readFile(method.location), font("Courier"), fontSize(11)));
} 

real calcComplexityPerc(int complexity){
	return complexity / 50.0; // calc the relative complexity percentage based on max allowed
}


//this function creates the property that is used for the size of the box
FProperty createBoxSize(int complexity, int unitSize){
	real complexityPerc = complexity / 50.0; // calc the relative complexity percentage based on max allowed
	real sizePerc = unitSize / 300.0; // calc the relative size percentage based on max allowed
	real complexityPoints = complexityPerc * 100.0; // assign (penalty) points
	real sizePoints = sizePerc * 100.0; // assign (penalty) points

	return size(complexityPoints, sizePoints);
}

Color generateColor(real percentage){
	int redColor = toInt(255.0 * percentage); // assign red color based on percentage
	int greenColor = 255 - redColor; // fill the rest with green
	return rgb(redColor, greenColor, 0);
}

//not used
str getDataString(){
	str result = "";
	if(complexityEnabled){
		result += "complexity enabled     ";
	}else{
		result += "complexity dissabled     ";
	}
	
	if(unitSizeEnabled){
		result += "unitSize enabled";
	}else{
		result += "unitSize dissabled";
	}
	return result;
}


// helper function: The helper function copy copies an element a number of times: for example, copy(3,"a") results in list[str]: ["a","a","a"]. 
list[&T] copy(int n, &T element) {
	return [ element | _ <- [0..n] ];
}

public bool aflopend(tuple[&a, num] x, tuple[&a, num] y) {
	return x[1] > y[1];
}


int calcPenaltyPoints(int complexity, int unitSize){
	real complexityPerc = calcComplexityPerc(complexity); // calc the relative complexity percentage based on max allowed
	real sizePerc = unitSize / 300.0; // calc the relative size percentage based on max allowed
	
	real complexityPoints = complexityPerc * 100.0; // assign (penalty) points
	real sizePoints = sizePerc * 100.0; // assign (penalty) points
	
	int totalPoints = 0;
	if(complexityEnabled){ // can be disabled, not implemented
		totalPoints += toInt(complexityPoints);
	}
	if(unitSizeEnabled){ // can be disabled, not implemented
		totalPoints += toInt(sizePoints);
	}

	return totalPoints;
}

// ==================================================== SORTING ===========================================================
public bool sortUnitsize(&Class a, &Class b){
	return a[2] > b[2];
}

public bool sortComplexity(&Class a, &Class b){
	return a[1] > b[1];
}


// ==================================================== TESTING ===========================================================
list[Class] getDummyData(){
	return [
		<"Klasse1", 9, 200, |project://smallsql/src/smallsql/database|, [<"Methode1_1", 4, 20, |project://smallsql/src/smallsql/database|>, <"Methode1_2", 14, 210, |project://smallsql/src/smallsql/database|>, <"Methode1_3", 16, 78, |project://smallsql/src/smallsql/database|>]>,
		<"Klasse2", 6, 100, |project://smallsql/src/smallsql/database|, [<"Methode2_1", 6, 100, |project://smallsql/src/smallsql/database|>]>,
		<"Klasse3", 2, 50, |project://smallsql/src/smallsql/database|, [<"Methode3_1", 12, 50, |project://smallsql/src/smallsql/database|>]>,
		<"Klasse4", 12, 150, |project://smallsql/src/smallsql/database|, [<"Methode4_1", 12, 50, |project://smallsql/src/smallsql/database|>]>,
		<"Klasse5", 45, 48, |project://smallsql/src/smallsql/database|, [<"Methode8=5_1", 12, 50, |project://smallsql/src/smallsql/database|>]>,
		<"Klasse6", 31, 68, |project://smallsql/src/smallsql/database|, [<"Methode6_1", 12, 50, |project://smallsql/src/smallsql/database|>]>,
		<"Klasse7", 2, 10, |project://smallsql/src/smallsql/database|, [<"Methode7_1", 12, 50, |project://smallsql/src/smallsql/database|>]>,
		<"Klasse8", 100, 77, |project://smallsql/src/smallsql/database|, [<"Methode8_1", 14, 400, |project://smallsql/src/smallsql/database|>]>
	];
}
