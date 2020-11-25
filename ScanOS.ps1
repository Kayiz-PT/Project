Get-ADComputer -Filter 'operatingsystem -notlike "*server*" -and enabled -eq "true"' `
-Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address |
Sort-Object -Property Operatingsystem |
Select-Object -Property Name | Out-File -FilePath C:\Users\Administrator\Desktop\Computers.txt
$colcomputer =Get-Content -Path C:\Users\Administrator\Desktop\Computers.txt
foreach ($strcomputer in $colComputers)
{
    Write-Warning "$strcomputer"
    $Manufacturer = Get-WmiObject -ComputerName $strcomputer -class win32_computersystem | select -ExpandProperty Manufacturer
    $Model = Get-WmiObject -class win32_computersystem -ComputerName $strcomputer | select -ExpandProperty model
    $Serial = Get-WmiObject -class win32_bios -ComputerName $strcomputer | select -ExpandProperty SerialNumber
    $wmi_cpu = Get-WmiObject -class Win32_Processor -ComputerName $strcomputer | select -ExpandProperty DataWidth
    $wmi_memory = Get-WmiObject -class cim_physicalmemory -ComputerName $strcomputer | select Capacity | %{($_.Capacity / 1024kb)}
    $DNName = Get-ADComputer -Filter "Name -like '$strcomputer'" | select -ExpandProperty DistinguishedName
    $Boot=[System.DateTime]::ParseExact($($wmi_os.LastBootUpTime).Split(".")[0],'yyyyMMddHHmmss',$null)
    [TimeSpan]$uptime = New-TimeSpan $Boot $(get-date)
    Write-Host "------Computer Info for $strcomputer------------------`r"
    Write-Host "$DNName"
    Write-Host "$Manufacturer $Model SN`:$Serial"
    Write-Host "$($wmi_os.Caption) $wmi_build $($wmi_os.OSArchitecture) $($wmi_os.Version)"
    Write-Host "CPU Architecture: $wmi_cpu"
    Write-Host "Memory: $wmi_memory"
    Write-Host "Uptime`: $($uptime.days) Days $($uptime.hours) Hours $($uptime.minutes) Minutes $($uptime.seconds) Seconds"
    Write-Host "--------------------------------------------------------"
}