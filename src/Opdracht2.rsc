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

// Zou methodes ook kunnen opvragen dmv een nieuwe methode met als arugment de loc.
alias Class = tuple[str name,int complexity,int unitsize, loc location, list[Method] methods];
alias Method = tuple[str name, int complexity, int unitsize, loc location];

public void run(){
	println("Hello");
	list[Class] infodata = getData();
}

public list[Class] getData(){
	list[Class] infodata = [
		<"Eerste klasse", 40, 90, |project://example-project/src/HelloWorld.java|, [<"methode1", 5, 20, |project://example-project/src/HelloWorld.java|>]>,
		<"Tweede klasse", 40, 90, |project://example-project/src/HelloWorld.java|, [<"methode1", 5, 20, |project://example-project/src/HelloWorld.java|>]>
	];
	return infodata;
}


