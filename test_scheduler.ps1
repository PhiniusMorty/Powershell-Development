<#----------------------------------------------------------------------------------------------------#---------------------------------------->
 @Author: Raj Ashish <Phinius_Morty>
 @Date:   2019-08-22 T15:22:20+05:30
 @Email:  ashishr1997@gmail.com
 @Filename: test_service.ps1
 @Last modified by:   Phinius_Morty
 @Last modified time: 2019-08-22 T12:23:49+05:30
------------------------------------------------------------------------------------------------------#----------------------------------------#>

cls
$path = "C:\Users\Admin\Desktop\Project"
$input1 = $path + "\Tasks.csv"
$input2 = $path + "\Operations.csv"
$Logfile = $path + "\Lgfile.log"
$finalReport = $path + "\status.csv"

$oops = get-content $input2
$oops = $oops -split","
$arr = get-content $input1 
$arr = $arr -split","

#To log the task
function logwrite($msg){
      
      $FormattedDate = Get-Date -Format "[yyyy-MM-dd HH:mm:ss]"
      $Logfile = $path + "\Lgfile.log"
      $msgin = "$FormattedDate $msg"
      $msgin | Out-File -FilePath $Logfile -Append
}

#To stop the task 
function StopTask($Task) {

if (Get-ScheduledTask $Task -ErrorAction SilentlyContinue)
	{
		if ((Get-ScheduledTask $Task).Status -eq 'Running')
			{
                
                if((Get-ScheduledTask $Task).state -eq 'Disabled' ){
                    logwrite "ERROR: $Task state Type is Disabled. Status cannot be stopped."
                }
                else{
                    Get-ScheduledTask -TaskName $Task | Stop-ScheduledTask
				    $TaskStatus = (Get-ScheduledTask $Task).State
                    if($TaskStatus -ne 'Ready'){
                
                        for($j=0,$j -lt 3;$j++){
                            logwrite "WARNING: $Task - Retrying...$j"
                            Get-ScheduledTask -TaskName $Task | Stop-ScheduledTask
                            $TaskStatus = (Get-ScheduledTask $Task).State
                            Sleep 5
                            if($TaskStatus -eq 'Ready'){
                                break    }
                            }
                        $TaskStatus = (Get-ScheduleSdTask $Task).State
                        if($TaskStatus -ne 'Ready'){
                            logwrite "ERROR: $Task Status cannot be changed. Status- $TaskStatus."
                            break
                             }
                        else{logwrite "INFO: $Task - $TaskStatus"}
                    }
				    else{logwrite "INFO: $Task - $TaskStatus"}
                    }
                }
                
			
		elseif ((Get-ScheduledTask $Task).State -eq 'Ready')
			{
                $TaskStatus = (Get-ScheduledTask $Task).State
                if((Get-ScheduledTask $Task).state -eq 'Disabled' ){
                logwrite "ERROR: $Task state Type is Disabled. Status cannot be changed.Status- $TaskStatus."
                }
                else{
				$TaskStatus = (Get-ScheduledTask $Task).State
                logwrite "WARNING:$Task already has a Status - $TaskStatus "}	
                }
		else
			{
                if((Get-ScheduledTask $Task).state -eq 'Disabled' ){
                logwrite "ERROR: $Task state Type is Disabled. Status cannot be changed. Status- $TaskStatus."
                }
                else{
                    Get-ScheduledTask -TaskName $Task | Stop-ScheduledTask
				    $TaskStatus = (Get-ScheduledTask $Task).State
                    if($TaskStatus -ne 'Ready'){
                        for($j=0,$j -lt 3;$j++){
                            logwrite "WARNING: $Task Retrying...$j"
                            Get-ScheduledTask -TaskName $Task | Stop-ScheduledTask
                            $TaskStatus = (Get-ScheduledTask $Task).State
                            Sleep 5
                            if($TaskStatus -eq 'Ready'){
                                break    }      
                            }
                         if($TaskStatus -ne 'Ready'){
                            logwrite "ERROR: $Task Status cannot be changed. Status- $TaskStatus."
                            break
                             }
                         else{logwrite "INFO: $Task - $TaskStatus"}}
                    else{logwrite "INFO: $Task - $TaskStatus"}
                    }
			}
	}
else
	{
		logwrite "WARNING: $Task not found"
	}
}

#To Enable the task
function EnableTask($Task){
if (Get-ScheduledTask $Task -ErrorAction SilentlyContinue)
	{
		if ((Get-ScheduledTask $Task).state -eq 'Disabled')
		{
            Get-ScheduledTask -TaskName $Task | Enable-ScheduledTask
            if((Get-ScheduledTask $Task).state -eq 'Disabled'){
                for($j=0,$j -lt 3;$j++){
                        logwrite "WARNING:$Task Retrying...$j"
                        Get-ScheduledTask -TaskName $Task | Enable-ScheduledTask
                        Sleep 5
                        if((Get-ScheduledTask $Task).state -eq 'Ready'){
                            break    }
                        }
                if((Get-ScheduledTask $Task).state -eq 'Disabled'){
                    logwrite "ERROR: $Task state type cannot be set to Enabled state."}
                else{
                    logwrite "INFO:$Task state Type is Enabled Successfully."}
            }
            else{
                logwrite "INFO:$Task state Type is Enabled Successfully."}    
        }
        	
		else
		{
                logwrite "WARNING: $Task state Type is in Enabled state."
        }
	}
else
	{
		logwrite "WARNING: $Task not found"
	}
}

#To Disable the task
function DisableTask($Task) {
if (Get-ScheduledTask $Task -ErrorAction SilentlyContinue)
	{
		if ((Get-ScheduledTask $Task).state -eq "Disabled")
		{
            logwrite "WARNING: $Task State Type is already in Disabled state."
        }	
		else
		{
            Get-ScheduledTask -TaskName $Task | Stop-ScheduledTask
            Get-ScheduledTask -TaskName $Task | Disable-ScheduledTask
            if((Get-ScheduledTask $Task).state -ne 'Disabled'){
                for($j=0,$j -lt 3;$j++){
                        logwrite "WARNING: $Task Retrying...$j"
                        Get-ScheduledTask -TaskName $Task | Stop-ScheduledTask
                        Get-ScheduledTask -TaskName $Task | Disable-ScheduledTask
                        Sleep 5
                        if((Get-ScheduledTask $Task).state -eq "Disabled"){
                            break    }
                        }
                if((Get-ScheduledTask $Task).state -ne 'Disabled'){
                    logwrite "ERROR: $Task State type cannot be set to disabled."}
                else{
                    logwrite "INFO:$Task State Type is Disabled Successfully."}
            }
            else{
                logwrite "INFO:$Task State Type is Disabled Successfully."}    
        }
	}
else
	{
		logwrite "WARNING: $Task not found"
	}
}

#To Delete the task
<#function DeleteTask($Task){
#if (Get-ScheduledTask $Task -ErrorAction SilentlyContinue){
#    Get-ScheduledTask -TaskName $Task | Unregister-ScheduledTask
#    if(Get-ScheduledTask $Task -ErrorAction SilentlyContinue){
#        for($j=0,$j -lt 3;$j++){
#            logwrite "WARNING: $Task Retrying...$j"
#            Get-ScheduledTask -TaskName $Task | Unregister-ScheduledTask
#            sleep 5
#            if(Get-ScheduledTask $Task){continue}
#            else{break}
#            }
#        if(Get-ScheduledTask $Task -ErrorAction SilentlyContinue){logwrite "ERROR: $Task cannot be removed."}
#        else{logwrite "INFO: $Task removed successfully."}
#        }
#    else{logwrite "INFO: $Task removed successfully."}
#    }
#else{logwrite "WARNING: $Task cannot be found."}
#}
#>

#To start the task
function StartTask($Task) {
    if (Get-ScheduledTask $Task -ErrorAction SilentlyContinue)
	{
		if ((Get-ScheduledTask $Task).State -eq 'Running')
			{
				$TaskStatus = (Get-ScheduledTask $Task).State
                if((Get-ScheduledTask $Task).state -eq "Disabled" ){
                    logwrite "ERROR: $Task state Type is Disabled. Status cannot be changed.Status- $TaskStatus."
                }
                else{
				    $TaskStatus = (Get-ScheduledTask $Task).state
                    logwrite "WARNING:$Task already has a Status - $TaskStatus "}
			}

		elseif ((Get-ScheduledTask $Task).State  -eq 'Ready')
			{
               if((Get-ScheduledTask $Task).state -eq "Disabled" ){
                    $TaskStatus = (Get-ScheduledTask $Task).State
                    logwrite "ERROR: $Task state Type is Disabled. Status cannot be changed. Status- $TaskStatus."

                }
                else{
                    Get-ScheduledTask -TaskName $Task | Start-ScheduledTask
				    $TaskStatus = (Get-ScheduledTask $Task).State
                    if($TaskStatus -ne 'Running'){
                        for($j=0,$j -lt 3;$j++){
                            logwrite "WARNING:$Task Retrying...$j"
                            Get-ScheduledTask -TaskName $Task | Start-ScheduledTask
                            $TaskStatus = (Get-ScheduledTask $Task).State
                            Sleep 5
                            if($TaskStatus -eq 'Running'){
                                break    }
                            }
                        $TaskStatus = (Get-ScheduledTask $Task).State
                        if($TaskStatus -ne 'Running'){
                            logwrite "ERROR: Status cannot be changed. Status- $TaskStatus."
                            break
                             }
                        else{logwrite "INFO: $Task - $TaskStatus"}
                    }
				    else{logwrite "INFO: $Task - $TaskStatus"}
                    }
                }	
		else
			{
                if((Get-ScheduledTask $Task).state -eq "Disabled"){
                    $TaskStatus = (Get-ScheduledTask $Task).State
                    logwrite "ERROR: $Task state Type is Disabled. Status cannot be changed. Status- $TaskStatus."

                }
                else{
                    Get-ScheduledTask -TaskName $Task | Start-ScheduledTask
				    $TaskStatus = (Get-ScheduledTask $Task).State
                    if($TaskStatus -ne 'Running'){
                        for($j=0,$j -lt 3;$j++){
                            logwrite "WARNING:$Task Retrying...$j"
                            Get-ScheduledTask -TaskName $Task | Start-ScheduledTask
                            $TaskStatus = (Get-ScheduledTask $Task).State
                            Sleep 5
                            if($TaskStatus -eq 'Running'){
                                break    }
                            }
                        $TaskStatus = (Get-ScheduledTask $Task).State
                        if($TaskStatus -ne 'Running'){
                            logwrite "ERROR: Status cannot be changed. Status- $TaskStatus."
                            break
                             }
                        else{logwrite "INFO: $Task - $TaskStatus"}
                    }
				    else{logwrite "INFO: $Task - $TaskStatus"}
                    }
			}
	}
else
	{
		logwrite "WARNING: $Task not found"
	}
}

#To loop through the tasks
foreach($i in $arr){

if ($oops -eq "stop"){
StopTask $i
}

elseif($oops -eq "Enable"){
EnableTask $i
}

elseif($oops -eq "Disable"){
DisableTask $i
}

elseif($oops -eq "Delete"){
DeleteTask $i
}

elseif ($oops -eq "start"){
StartTask $i
}

else{
logwrite "ERROR: Operation not specified."}
}

#To Report status of the task
$Reports = @()
foreach($i in $arr){
if (Get-ScheduledTask $i -ErrorAction SilentlyContinue){
    <#$rest4 = (Get-ScheduledTask $i).NextRunTime
    $rest1 = (Get-ScheduledTask $i).TaskName
    $rest2 = (Get-ScheduledTask $i).State
    $rest3 = Get-ScheduledTaskInfo -TaskName "Task1" | Select-Object LastRunTime

    $Report = New-Object System.Object
	$Report | Add-Member -MemberType NoteProperty -Name "Task Name" -Value $rest1
	$Report | Add-Member -MemberType NoteProperty -Name "State" -Value $rest2
    $Report | Add-Member -MemberType NoteProperty -Name "LastRunTime" -Value $rest3
    $Report | Add-Member -MemberType NoteProperty -Name "NextRunTime" -Value $rest4#>
    $Report=Get-ScheduledTask -TaskName $i | Get-ScheduledTaskInfo | Sort-Object TaskName
	
	$Reports += $Report
}
else{continue}
}
$Reports | Export-Csv -NoTypeInformation -Path $finalReport

#for distinction between logs
$msgend = "---------*----------*---------*----------*---------*----------*---------*----------*---------*----------*---------*----------"
$msgend | Out-File -FilePath $Logfile -Append
