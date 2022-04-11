#Precipitation-prevision
Projet de statistique appliquée à la climatologie sous MatLab
D’après les tests de tendance et stationnaire, que ce soit statistique ou graphique qu’on a fait, on peut en
déduire que la série en occurrence est **Non-Stationnaire**. La série temporelle présente à
la fois une tendance et une saisonnalité, il est donc possible d’utiliser le modèle **_SARIMA_** qui est un
modèle ARIMA prenant aussi en compte une composante saisonnière.


![GraphResult](/graph_results/TendanceEnleve.jpg)

Pour faire la prédiction et la prévision, on va utiliser le modèle SARIMA parce que notre série temporelle
présente de saisonnalité dans notre série. La durée de la prévision sera 6 mois parce que c’est l’été dans
2010-2011. Voici le resultat finale de notre prévision
![GraphResult](/graph_results/prevision_figure.jpg)
