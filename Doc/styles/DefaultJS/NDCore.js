﻿/*
This file is part of Natural Docs, which is Copyright © 2003-2022 Code Clear LLC.
Natural Docs is licensed under version 3 of the GNU Affero General Public
License (AGPL).  Refer to License.txt or www.naturaldocs.org for the
complete details.

This file may be distributed with documentation files generated by Natural Docs.
Such documentation is not covered by Natural Docs' copyright and licensing,
and may have its own copyright and distribution terms as decided by its author.
*/

"use strict";var NDCore=new function(){this.HasClass=function(element,targetClassName){if(element.className==undefined){return false;}var index=element.className.indexOf(targetClassName);if(index!=-1){if((index==0||element.className.charAt(index-1)==' ')&&(index+targetClassName.length==element.className.length||element.className.charAt(index+targetClassName.length)==' ')){return true;}}return false;};this.AddClass=function(element,newClassName){if(element.className==undefined){element.className=newClassName;return;}var index=element.className.indexOf(newClassName);if(index!=-1){if((index==0||element.className.charAt(index-1)==' ')&&(index+newClassName.length==element.className.length||element.className.charAt(index+newClassName.length)==' ')){return;}}if(element.className.length==0){element.className=newClassName;}else{element.className+=" "+newClassName;}};this.RemoveClass=function(element,targetClassName){if(element.className==undefined){return;}var index=element.className.indexOf(targetClassName);while(index!=-1){if((index==0||element.className.charAt(index-1)==' ')&&(index+targetClassName.length==element.className.length||element.className.charAt(index+targetClassName.length)==' ')){var newClassName="";if(index>0){newClassName+=element.className.substr(0,index);}if(index+targetClassName.length!=element.className.length){newClassName+=element.className.substr(index+targetClassName.length);}element.className=newClassName;return;}index=element.className.indexOf(targetClassName,index+1);}};this.LoadJavaScript=function(path,id){var script=document.createElement("script");script.src=path;script.type="text/javascript";if(id!=undefined){script.id=id;}document.getElementsByTagName("head")[0].appendChild(script);};this.RemoveScriptElement=function(id){var script=document.getElementById(id);script.parentNode.removeChild(script);};this.GetFullOffsets=function(element){var result={offsetTop:element.offsetTop,offsetLeft:element.offsetLeft};element=element.offsetParent;while(element!=undefined&&element.nodeName!="BODY"){result.offsetTop+=element.offsetTop;result.offsetLeft+=element.offsetLeft;element=element.offsetParent;}return result;};this.NormalizeHash=function(hashString){if(hashString==undefined){return"";}if(hashString.charAt(0)=="#"){hashString=hashString.substr(1);}hashString=decodeURI(hashString);return hashString;};this.IsIE=function(){return(navigator.userAgent.indexOf("MSIE")!=-1||navigator.userAgent.indexOf("Trident")!=-1);};this.IsEdgeHTML=function(){return(navigator.userAgent.indexOf("Edge")!=-1);};this.CaseInsensitiveAnchors=function(){return(this.IsIE()||this.IsEdgeHTML());};this.ChangePrototypeToNarrowForm=function(prototype){var newPrototype=document.createElement("div");newPrototype.id=prototype.id;newPrototype.className=prototype.className;this.RemoveClass(newPrototype,"WideForm");this.AddClass(newPrototype,"NarrowForm");var sections=prototype.children;for(var i=0;i<sections.length;i++){if(this.HasClass(sections[i],"PParameterSection")==false){newPrototype.appendChild(sections[i].cloneNode(true));}else{var newSection=document.createElement("div");newSection.className=sections[i].className;var table=sections[i].firstChild;var newTable=document.createElement("table");var newRow=newTable.insertRow(-1);newRow.appendChild(table.rows[0].cells[0].cloneNode(true));newRow=newTable.insertRow(-1);newRow.appendChild(table.rows[0].cells[1].cloneNode(true));newRow=newTable.insertRow(-1);newRow.appendChild(table.rows[0].cells[2].cloneNode(true));newSection.appendChild(newTable);newPrototype.appendChild(newSection);}}prototype.parentNode.replaceChild(newPrototype,prototype);};this.ChangePrototypeToWideForm=function(prototype){var newPrototype=document.createElement("div");newPrototype.id=prototype.id;newPrototype.className=prototype.className;this.RemoveClass(newPrototype,"NarrowForm");this.AddClass(newPrototype,"WideForm");var sections=prototype.children;for(var i=0;i<sections.length;i++){if(this.HasClass(sections[i],"PParameterSection")==false){newPrototype.appendChild(sections[i].cloneNode(true));}else{var newSection=document.createElement("div");newSection.className=sections[i].className;var table=sections[i].firstChild;var newTable=document.createElement("table");var newRow=newTable.insertRow(-1);newRow.appendChild(table.rows[0].cells[0].cloneNode(true));newRow.appendChild(table.rows[1].cells[0].cloneNode(true));newRow.appendChild(table.rows[2].cells[0].cloneNode(true));newSection.appendChild(newTable);newPrototype.appendChild(newSection);}}prototype.parentNode.replaceChild(newPrototype,prototype);};this.GetComputedStyle=function(element,style){var result=element.style[style];if(result!=""){return result;}if(window.getComputedStyle){return window.getComputedStyle(element,"")[style];}else{return undefined;}};this.GetComputedPixelWidth=function(element,style){var result=this.GetComputedStyle(element,style);if(this.pxRegex.test(result)){return parseInt(RegExp.$1,10);}else{return 0;}};this.pxRegex=/^([0-9]+)px$/i;};String.prototype.StartsWith=function(other){if(other===undefined){return false;}return(this.length>=other.length&&this.substr(0,other.length)==other);};String.prototype.EntityDecode=function(){var output=this;output=output.replace(/&lt;/g,"<");output=output.replace(/&gt;/g,">");output=output.replace(/&quot;/g,"\"");output=output.replace(/&amp;/g,"&");return output;};function NDLocation(hashString){this.Constructor=function(hashString){this.hashString=NDCore.NormalizeHash(hashString);var prefixSeparator=this.hashString.indexOf(':');var memberSeparator=-1;if(prefixSeparator==-1){this.prefix=undefined;this.path=undefined;this.member=undefined;}else{this.prefix=this.hashString.substr(0,prefixSeparator);memberSeparator=this.hashString.indexOf(':',prefixSeparator+1);if(memberSeparator==-1){this.path=this.hashString;this.member=undefined;}else{this.path=this.hashString.substr(0,memberSeparator);this.member=this.hashString.substr(memberSeparator+1);if(this.member==""){this.member=undefined;}}}var foundPrefix=false;var locationInfo=undefined;var prefixParam=undefined;if(this.hashString==""){this.type="Home";foundPrefix=true;}else if(NDFramePage!=undefined&&NDFramePage.locationInfo!=undefined){for(var i=0;i<NDFramePage.locationInfo.length;i++){var matchResult=this.prefix.match(NDFramePage.locationInfo[i][4]);if(matchResult){locationInfo=NDFramePage.locationInfo[i];this.type=locationInfo[0];prefixParam=matchResult[1];foundPrefix=true;break;}}}if(!foundPrefix){this.type="Home";}if(this.type=="Home"||locationInfo==undefined){this.contentPage="other/home.html";this.summaryFile=undefined;this.summaryTTFile=undefined;}else{var path=locationInfo[1];if(locationInfo[2]==0&&prefixParam!=undefined){path+=prefixParam;}else if(locationInfo[2]==1){path+='/'+prefixParam;}path+='/'+this.path.substr(prefixSeparator+1);if(locationInfo[2]==0){var lastSeparator=path.lastIndexOf('/');var folder=path.substr(0,lastSeparator+1);var file=path.substr(lastSeparator+1);file=file.replace(/\./g,'-');path=folder+file;}else{path=path.replace(/\./g,'/');}this.contentPage=path+".html";this.summaryFile=path+"-Summary.js";this.summaryTTFile=path+"-SummaryToolTips.js";if(this.member!=undefined){this.contentPage+='#'+this.member;}}};this.Constructor(hashString);};