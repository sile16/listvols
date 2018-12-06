$result=@()
ForEach($disk in Get-WmiObject -query "SELECT * FROM Win32_DiskDrive"){       
    ForEach($part in Get-WmiObject -query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID='$($disk.DeviceID)'} WHERE AssocClass = Win32_DiskDriveToDiskPartition"){
        ForEach($logicaldisk in Get-WmiObject -query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID='$($part.DeviceID)'} WHERE AssocClass = Win32_LogicalDiskToPartition"){
            $result+=New-Object PSObject -Property @{
            'System'=$disk.SystemName;
            'Name'=$logicaldisk.Caption;
            'Drive'=$disk.DeviceID;
            'Type'=$disk.Model.Substring(0,15);
            'Serial'=$disk.SerialNumber;
            'Partition'=$logicaldisk.DeviceID;
            'SizeTB'=[math]::Truncate($logicaldisk.Size / 1GB);
            'PercentFull'=[math]::Truncate(100 * (1 - ($logicaldisk.FreeSpace / $logicaldisk.Size )));
            }
        }
    }
}
$result | Select-Object System,Name,Drive,Type,Serial,Partition,SizeTB,PercentFull | Format-Table -AutoSize
