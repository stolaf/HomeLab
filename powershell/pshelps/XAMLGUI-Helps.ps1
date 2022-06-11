# http://wpftutorial.net/

Add-type -AssemblyName PresentationCore
Add-type -AssemblyName PresentationFramework

[xml]$XAML = @'
<Window x:Class="WpfApplication1.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Copy File/Folder to VM" Height="210" Width="500" >
    <Grid RenderTransformOrigin="0.547,0.48" Background="{DynamicResource {x:Static SystemColors.GradientActiveCaptionBrushKey}}" Margin="0,0,0.2,-29.8">
        <Label x:Name="Label1" Content="SourceFile" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" Width="186.993" ToolTip="File to Copy"/>
        <TextBox x:Name="Textbox1" HorizontalAlignment="Left" Height="26" Margin="10,36,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="293"/>
        <Button x:Name="Button1" Content="Browse" HorizontalAlignment="Left" Height="26" Margin="326,36,0,0" VerticalAlignment="Top" Width="85"/>
        <TextBox x:Name="Textbox3" HorizontalAlignment="Left" Height="26" Margin="10,164,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="293"/>
        <Label x:Name="Label3" Content="Destination" HorizontalAlignment="Left" Margin="10,136,0,0" VerticalAlignment="Top" Width="187"/>
        <Button x:Name="Button3" Content="Start Copy" HorizontalAlignment="Left" Height="26" Margin="326,164,0,0" VerticalAlignment="Top" Width="85" RenderTransformOrigin="0.579,3.023"/>
        <TextBox x:Name="Textbox2" HorizontalAlignment="Left" Height="26" Margin="10,91,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="293"/>
        <Label x:Name="Label2" Content="or SourceFolder" HorizontalAlignment="Left" Margin="10,67,0,0" VerticalAlignment="Top" Width="187" ToolTip="Folder to Copy"/>
        <Button x:Name="Button2" Content="Browse" HorizontalAlignment="Left" Height="26" Margin="326,91,0,0" VerticalAlignment="Top" Width="85"/>
    </Grid>
</Window>
'@
[xml]$XAML = @'
<Window x:Class="WpfApplication2.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApplication2"
        mc:Ignorable="d"
        Title="FoxDeploy Awesome Tool" Height="345.992" Width="530.344" Topmost="True">
    <Grid Margin="0,0,45,0">
        <Image x:Name="image" HorizontalAlignment="Left" Height="100" Margin="24,28,0,0" VerticalAlignment="Top" Width="100" Source="C:\Users\Stephen\Dropbox\Docs\blog\foxdeploy favicon.png"/>
        <TextBlock x:Name="textBlock" HorizontalAlignment="Left" Height="100" Margin="174,28,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="282" FontSize="16"><Run Text="Use this tool to find out all sorts of useful disk information, and also to get rich input from your scripts and tools"/><InlineUIContainer>
                <TextBlock x:Name="textBlock1" TextWrapping="Wrap" Text="TextBlock"/>
            </InlineUIContainer></TextBlock>
        <Button x:Name="button" Content="OK" HorizontalAlignment="Left" Height="55" Margin="370,235,0,0" VerticalAlignment="Top" Width="102" FontSize="18.667"/>
        <TextBox x:Name="textBox" HorizontalAlignment="Left" Height="35" Margin="221,166,0,0" TextWrapping="Wrap" Text="TextBox" VerticalAlignment="Top" Width="168" FontSize="16"/>
        <Label x:Name="label" Content="UserName" HorizontalAlignment="Left" Height="46" Margin="56,162,0,0" VerticalAlignment="Top" Width="138" FontSize="16"/>
 
    </Grid>
</Window>
'@

# $xaml	= Get-Content -Path '\\fsdebsgv4911\iopi_sources$\PowerShell\Modules\IH-IOPI\IH-IOPIGuiTools.xaml' -Raw
# $Null = Add-Type -AssemblyName PresentationFramework
# $reader = [System.XML.XMLReader]::Create([System.IO.StringReader] $xaml)
# $window = [System.Windows.Markup.XAMLReader]::Load($reader)

$XAML.Window.RemoveAttribute('x:Class')
$Reader = New-Object System.Xml.XmlNodeReader $XAML
$Window = [Windows.Markup.XamlReader]::Load($Reader)

#Connect to Control
$Button = $Window.FindName('Button1')
$TextBox = $Window.FindName('Textbox1')

#On click, change window background color
#$button.Add_Click({
#    $Window.Background = (Get-Random -InputObject 'Black','Red','Green','White','Blue','Yellow','Cyan')
#    Write-Host $TextBox.Text
#    $TextBox.Text = 'Ausgegeben !'
#})


$Window.ShowDialog() | Out-Null
