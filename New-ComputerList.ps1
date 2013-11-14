﻿<#
.Synopsis
   Create a computer list given a room name and range value
.DESCRIPTION
   Will create a computer list given a room name and range value without verifying if these names exist in the network.

   Pipeline output is an object with properties computerName

.EXAMPLE
   new-computerList -roomName 50 -range 8..11

   Output: 50-08, 50-09, 50-10, 50-11

.EXAMPLE
    new-computerList 40 -range 2,3,4,10 | copy-mimics
#>
function new-computerList
{
    [CmdletBinding()]
    Param
    (
        # Room number
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]
        $Room

        , # Start PC number, default is 1. leading zero is unnecessary
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [int[]]
        $Range = 1

        , #Add Full Qualified Domain name
        [switch]
        $FQDN = $false
    )

    Begin
    {
        # Create a list to add computer names to
        $computerName = New-Object System.Collections.Generic.List[string]

        #What's the fully qualified domain name in case we need it
            $domain = [ADSI]"LDAP://RootDSE"
        $domain = $domain.rootDomainNamingcontext -replace ",?DC=", "."
    }

    Process
    {
        # We need to build the string ROOM-COMPUTER
        
        # So for each room we've been given
        foreach($r in $room){
            Write-Verbose "Making list for Room: $r"

            # Make a computer for each of the ranges specified
            foreach($c in $range){
                Write-Verbose "adding computer: $c to the room list"
                # Add this string to our list of computernames with a fully qualified domain name
                $computerName.Add("$r-$($c.toString('00'))")
            }
        }

        if($FQDN)
        {
            Write-Verbose ('Adding FQDN [' + $domain + '] to all ' + $computerName.Count + ' computer names')
            for($i = 0; $i -lt $computerName.Count; ++$i)
            {
                $computerName[$i] += $domain
            }
        }
    }

    End
    {
        # Return the list of computer names to the pipeline
        Write-Verbose "Returning the list to pipeline"

        $obj = new-object -TypeName psobject | Add-Member -MemberType NoteProperty -Name "computerName" -Value $computerName

        return $obj
    }
}