clc; clear variables; close all;

% CHARGEMENT DE DONNEES 
% =====================
load data_pluie.txt;
data = data_pluie;
N = length(data);
intervalle = N/3;
duree_prevision = 6; % dans 2010 - 2011 = 1 ans. On a 6 mois d'été
saisonnalite = 6;
moyenne = mean(data);

% REPRESENTATION GRAPHIQUE DE LA SERIE
% ====================================
figure('name','Graphe de la série');
plot(repmat(moyenne, length(data)));
hold on;
plot(data);
grid on;
xlabel('Mois dans Année');
ylabel('Valeur de Précipitation');
title('Cumul mensuel de pluie');
legend('série','moyenne');

% REPRESENTATION DE FAC ET FACP
%==============================
figure 
subplot(2,1,1); 
autocorr(data,ceil(N/3));
% fonction d'autocorrelation xlabel('decalage'); ylabel('Fac');
title('Autocorrelation Simple');
subplot(2,1,2); 
parcorr(data,ceil(N/3));
% fonction d'autocorrelation partielle xlabel('decalage'); ylabel('FacP');
title('Autocorrelation Partielle')
legend('Fontion dautocorrelation partielle','Intervale de confiance');

%IL FAUT STABILISER LA VARIANCE
data_stable = log(data);
figure
plot(data_stable);
xlabel('x'); ylabel('Ln(data)');title('Courbe après correction Logarithmique');
%=> resultat f4 : variance redressé, au valeur de ordonnée Y
%TEST DE TENDANCE GRAPHIQUEMENT
%==============================
figure
plot(data);
xlabel('x'); ylabel('y');title('Graphe de verfication de tendance');
hold on 
moyenneMobile = mmob(data,13,1);
plot(moyenneMobile,'r');
%=> resultat fig3: Serie presque monotone, il n'y a pas de tendance

% TEST DE TENDANCE avec Mann Kendall
%===================================
[H,p_value]=mann_kendal(data,0.05);
if(H==1)
 disp('serie avec tendance')
else
 disp('serie sans tendance')
end

%TESTER SUIVANT LA DROITE DE REGRESSION
%======================================
% Estimation de la droite de régression afin d'apercevoir la tendance.
 N = length(data);
 t = [1:N]'
 moyenne = mean(data)
 equation = polyfit(t,data,1)
 f_de_t = polyval(equation , t )

% Afficher la droite de regression
figure
plot(data , '-o')
hold on
plot(f_de_t)
hold on
plot(repmat(moyenne, length(data)), 'LineWidth', 2, 'color', 'black')

% resultat : La droite de regression diminue, alors on constate qu'on a une
% tendance decroissante.

%TEST DE STATIONNARITE STATISTIQUE
%=================================
% test de Dickey-Fuller : (test de racine unitaire)
[h1,pValue1]=adftest(data);
% h1=0 : la série comporte une racine
% h1=1 : la série ne comporte pas de racine unitaire, la série est stationnaire.
%b) Test de KPSS ; Kwiatkowski, Phillips, Schmidt et Shin, 1981)
[h2,pValue2]=kpsstest(data);
% h2=0 : la série est stationnaire
% h2=1 : la série n'est pas stationnaire
% Test de Phillips-Perron
[h3,pValue3]=pptest(data);
% h3=0 : la série possède une racine unitaire
% h3=1 : la série ne possède pas une racine unitaire.
%
if(h1==0)
 disp('Hickey-fuller => la série comporte une racine unitaire.')
else
 disp('Hickey-fuller => Aucune racine unitaire.La série est stationnaire.')
end
if(h2==0)
 disp('KPSS => H2=0 La série est stationnaire.')
else
 disp('KPSS => La série est non-stationnaire.')
end
if (h3==0)
 disp('pptest => La série possède une racine unitaire')
else
 disp('pptest => Aucune racine unitaire.La série est stationnaire.')
end

%MODELISATION DE LA SERIE STATIONNAIRE
%=====================================
% DIFFERIENCIATION
% ================
% Objectif: Enlever la tendance
% 1 - D'ordre 1
D1 = LagOp({1,-1},'Lags',[0,1]);
dY1 = filter(D1,data_stable);
figure
subplot(2,1,1);
plot(dY1);
title('Graphe après correction de tendance D=1');
grid on

% DIFFERENCIATION SAISONNIERE
% ===========================
% Objectif: Enlever la saisonnalité
DS2 = LagOp({1,-1},'Lags',[0,6]);
ddY = filter(DS2,data_stable);
figure
plot(ddY,'-o');
grid on
xlabel('X');
ylabel('Y');
title('Graphe après correction de Saisonnalité');
%=> resultat fig5: les saisonnalités sont enlevées

% 4. Enlever la tendance et la saisonnalité
% Objectif: Enlever a la fois la tendance et la saisonnalite

d1 = LagOp({1, -1}, 'Lags', [0,1]);
d2 = LagOp({1, -1}, 'Lags', [0, 6]);
d12 = d1 * d2 ; 
serie_stationarise = filter(d12, data_stable);
longueur = N - length(serie_stationarise) + 1 ;
t2 = [longueur:126]'
moymob2 = mmob(serie_stationarise, 6, 1)
moyenne2 = mean(serie_stationarise)
equation2 = polyfit(t2,serie_stationarise,1)
f_de_t2 = polyval(equation2 , t2 )

figure('Name','Tendance et saisonalité enlevées')
plot(serie_stationarise , '-o')
hold on
plot(moymob2)
hold on 
plot(f_de_t2 ,'LineWidth', 2,'color','black')
% 5. REPRESENTATION GRAPHIQUE DE LA NOUVELLE FAC ET FACP
% POUR TROUVER LA VALEUR DE p et q
figure
subplot(2,1,1);
autocorr(serie_stationarise,ceil(N/3));
xlabel('Intervalle'); ylabel('FAC');title('FAC après Différenciation Saisonière');
subplot(2,1,2);
parcorr(serie_stationarise,ceil(N/3)); % fonction d'autocorrelation
xlabel('Intervalle'); ylabel('FacP');title('FACP après Différenciation Saisonière');
% resultat fig6: q = 1 (le pic successif non significatif dans FAC)
% et p = 2 ( c'est le nombre de deux pic successif non significatifs dans FACP)

% 5. ESTIMATION 
%SARIMA(p,d,q)*(P,D,Q) * 6
% p=0 => SARIMA(0,1,2)*(0,1,1)6
modele_1 = arima('Constant',0,'MALags',2,'SMALags',saisonnalite,'D',1,...,
    'Seasonality',saisonnalite);
fil1=estimate(modele_1,data_stable);

% p=1 => SARIMA(1,1,2)*(0,1,1)6
modele_2 = arima('MALags',2,'ARLags',1,'SMALags',saisonnalite,'D',1,...,
    'Seasonality',saisonnalite);
fil2=estimate(modele_2,data_stable);

% p=2 => SARIMA(2,1,2)*(0,1,1)6
modele_3 = arima('MALags',2,'ARLags',2,'SMALags',saisonnalite,'D',1,...,
    'Seasonality',saisonnalite);
fil3 = estimate(modele_3,data_stable);

%Maintenant on va chercher les valeurs de aic et bic pour chaque modèle
%Les minimum aic,bic est le modèle le plus favorable

[~,~,logL(1)]=estimate(modele_1,data); 
[~,~,logL(2)]=estimate(modele_2,data);
[~,~,logL(3)]=estimate(modele_3,data);
T=55; 
[aic,bic]= aicbic(logL,([1;2;3]),T*ones(3,1));
%=> Bon modèle = Modele 1 avec p = 1 
% Verification de residus pour voir s'il est non autocorrellé ou non
 residus =  infer(fil2,data_stable);
 %corellogramme du residu
figure
autocorr(residus,intervalle);
%=> fg7: Les residus sont presque significatives, non autocorellé, on
% On a de bruit blanc donc Le Modèle est acceptable
figure
qqplot(residus);
%=> fg8: la plupart des residus sont proche de la droite alors, le modèle
%bon

[Yf,YMSE] = forecast(fil2,duree_prevision,'Y0',data_stable);
Sup = Yf+1.96*sqrt(YMSE);
Inf = Yf - 1.96 * sqrt(YMSE);
figure
plot(data_stable);
hold on
plot(N+1:N+duree_prevision,Yf,'r','LineWidth',2);
plot(N+1:N+duree_prevision,Sup,'k--','LineWidth',1.5);
plot(N+1:N+duree_prevision,Inf,'k--','LineWidth',1.5);
xlim([0,N+duree_prevision]);

Yf_expo = exp(Yf);
disp(Yf_expo);
[h_lb, p_lb] = lbqtest(residus);% box lung test
% h = 0, les résidus sont non autocorelés, h = 1 le cas contraire

