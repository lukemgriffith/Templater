function FlushTemplate {
    param (
        [Object]$Template,
        [String]$Target
    )
    

    ValidateTemplate -Tempalte $Template -ErrorAction Stop

    Write-Verbose ("Processing template {0}" -f $Template.Name)

    $item = $Template.Children
    
    ProcessTemplateItem -parentPath $Target -template $item
    
    
}

function ProcessTemplateItem {
    param(
        $parentPath,
        $template
    )

    Write-Verbose ("Processing {0} to {1}" -f $template.name, $parentPath)

    $parent = WriteItem -parentPath $parentPath -item $template

    if (HasChildren($template)) {
        $template.Children | ForEach-Object {
            $item = $_
            ProcessTemplateItem -parentPath $parent.fullname -template $item
        }
    }


}


function HasChildren {
    
    param($object)
    
    return -not $null -eq $object.children    
}


function WriteItem {
    param($parentPath, $item)

    $param = @{}

    switch ($item.type) {
        "Document" {
            $param["ItemType"] = "File"
            $param["Value"] = $item.Body
        }
        "Directory" {
            $param["ItemType"] = "Directory"
        }
    }
    Write-Verbose ("Writing {0} item {1} at {2}" -f $item.type, $item.Name, $parentPath  )
    New-Item -Path $parentPath -Name $item.Name @param

}

function ValidateTemplate {
    [cmdletbinding()]
    param(
        $Tempalte
    )
    if ($Template.Children.Count -gt 1){
        Write-Error -Exception (New-Object System.ArgumentException) -Message "Tempalte is not valid, more than one root child."
    } 
}
