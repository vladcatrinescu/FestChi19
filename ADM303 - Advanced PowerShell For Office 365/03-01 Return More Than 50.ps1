try 
{
    for ($i=0;;$i+=50)
	{
        $ExternalUsers += Get-SPOExternalUser -PageSize 50 -Position $i -ea Stop
    }
}
catch 
{

}
$ExternalUsers.Count

