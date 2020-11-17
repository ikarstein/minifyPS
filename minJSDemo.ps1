cls

Remove-Module "minjs" -Force #-ErrorAction SilentlyContinue
Import-Module (join-path (split-path $MyInvocation.mycommand.path) "minjs")

$str = @"
	/* Some JavaScript */
	
	//This script code does not make any sense!
	
	var test = "this is a \"test\"";
	test = 'this is a \"test\'';
	
	var YOU_SHOULD_/* Remove this
	this
	this
	*/REMOVE_THIS_CONTENT='###';
    
	//comment!
	var variable="'DO NOT /* Remove this
	this\"///////////////
	this/////////////////
	*/REMOVE THIS (because it's inside a string);'";
	
		 /////////
		//       //
		// *   * //
		//   #   //
		//       //
		//  \/   //
		 //     //
		  /////
	
	'NO
	REMOVE';
	
	thisIs = "/*A multi line 
	comment*/ inside a string";
	
    function someFunction<%=TS%>(){
        if ( ready<%=TS%> ) return;

        ready<%=TS%> = true;

        // bla bla bla
        if ( location.href ) {
            someOtherMethod("DOMContentLoaded", function(){
                    document.removeEventListener( "parameterValue", arguments.callee, false );
                    ready<%=TS%>();
            }, false );
        }
    }

    someFunction<%=TS%>();

    function ready<%=TS%>() {
        isReady<%=TS%> = true;

        ExecuteOrDelayUntilScriptLoaded(activeRibbonTab<%=TS%>, "sp.ribbon.js" );
    }

    function sharePointFunction<%=TS%>() {     
        try {         
            if (typeof (_sharePointInternalFunction) == "function" ) {             
                _ribbonStartInit(sharePointFunction<%=TS%>, false, null);
            } 
            
            if (true && typeof (_sharePointInternalFunction) == 'function' && !_sharePointInternalFunction()) {             
                window.setTimeout("sharePointFunction<%=TS%>", 100);         
            }     
        } catch (e2) {     };
    };
	
"@

#create sub directory "output"
if( !(test-path (join-path (split-path $MyInvocation.mycommand.path) "output")) ) {
	New-Item -Name "output" -ItemType "container" -Path (split-path $MyInvocation.mycommand.path) 
}

minify -inputData $str -inputDataType "js" -xmlOutputFile (join-path (split-path $MyInvocation.mycommand.path) "output\javascript.xml")

# this minifies the "Code.Debug.JS" file of MS SharePoin 2010.
#$d1 = [datetime]::Now
#$sharepointCoreJS = Get-Content "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\14\TEMPLATE\LAYOUTS\1031\CORE.debug.js"
#(minify -inputData $sharepointCoreJS -inputDataType "js" -verbose:$false -xmlOutputFile ((join-path (split-path $MyInvocation.mycommand.path) "core.min.xml"))) | Set-Content (join-path (split-path $MyInvocation.mycommand.path) "core.min.js")
#Write-Host ([datetime]::Now.Subtract($d1).TotalSeconds)

$myself = Get-Content ($MyInvocation.mycommand.path)
$minmyself = (minify -inputData $myself -inputDataType "ps1" -xmlOutputFile ((join-path (split-path $MyInvocation.mycommand.path) "output\minJSDemo.min.xml"))) 
$minmyself = $minmyself.Replace("Remove-Module ""minjs""", "Remove-Module ""minjsmin""")
$minmyself = $minmyself.Replace("mycommand.path)""minjs"")", "mycommand.path)""minjsmin"")")
$minmyself = $minmyself.Replace("mycommand.path)""minjs.psm1"")", "mycommand.path)""minjsmin.psm1"")")
$minmyself | Set-Content ((join-path (split-path $MyInvocation.mycommand.path) "output\minJSDemo.min.ps1"))

#minify the minJS module itself
$myself = Get-Content (join-path (split-path $MyInvocation.mycommand.path) "minjs.psm1")
(minify -inputData $myself -inputDataType "ps1" -xmlOutputFile (join-path (split-path $MyInvocation.mycommand.path) "output\minjsmin.xml")) | Set-Content (join-path (split-path $MyInvocation.mycommand.path) "output\minjsmin.psm1")

