# Projektname: [Entwicklung und Evaluierung der Aussagekraft eines Statistikmodells über Schadenerwartungen in der KFZ-Haftpflichtversicherung]

## Beschreibung
Dieses Repository enthält den Quellcode und die synthetische Daten zur Modellierung und zum Vergleich von [Dein Thema]. Hierbei stelle ich aus rechtlichen Gründen nicht meine verwendeten Daten zur Verfügung.

## Zitierung
Wenn Sie dieses Projekt in Ihrer Arbeit verwenden, zitieren Sie bitte wie folgt:

DOI: [10.5281/zenodo.14886955](https://doi.org/10.5281/zenodo.14886955)

## Lizenzierung
Die Inhalte dieses Repositories unterliegen den folgenden Lizenzen:

- **Dokumentation (README, Beschreibungstexte):** [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/)  
  Namensnennung erforderlich, keine kommerzielle Nutzung erlaubt.
  
- **Source Code (R-Skripte):** [GNU General Public License v3.0 (GPL-3.0)](https://www.gnu.org/licenses/gpl-3.0.html)  
  Nutzung, Modifikation und Weitergabe erlaubt – solange die Nutzung nicht kommerziell ist und der Quellcode offengelegt wird.

- **Daten (synthetische Datensätze):** [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/)  
  Namensnennung erforderlich, keine kommerzielle Nutzung erlaubt.

## Reproduzierbarkeit
Um die Analysen zu reproduzieren, folgen Sie bitte diesen Schritten (R-Version 4.4.1):

1. Laden Sie die erforderlichen R-Pakete herunter und installieren Sie sie.
   Die benötigten Pakete sind in der Datei `packages.R` aufgelistet und können automatisch installiert werden.

Modellerstellung & Vergleich
Das Skript Modell_Erstellung_Vergleich.R erstellt und vergleicht die verwendeten Modelle basierend auf dem Datensatz synthetic_data.csv.

SMOTE-Datenerstellung
Mit dem Skript SMOTE_Datacreation.R wird ein Datensatz erstellt, bei dem die Klassenverteilung mithilfe der SMOTE-Methode ausgeglichen wird.

Modellvergleich auf SMOTE-Daten
Das Skript SMOTE_COMP.R vergleicht ein lineares Regressionsmodell mit einem neuronalen Netzwerk basierend auf den SMOTE-Daten.
