function [MM]=mmob(X,n,nmin);
%    mm=MMOB(x,n,nmin)
%
% CALCULE UNE MOYENNE MOBILE SUR UNE SERIE EVENTUELLEMENT LACUNAIRE
% X=série étudiée
%   (X peut etre une matrice, auquel cas la m.m. est calculée sur chq colonne)
% N=largeur de la fenetre de calcul de la moyenne mobile (impaire)
% NMIN=nombre minimum de valeurs non manquantes pour chaque calcul
% MM=série ou matrice après filtrage

[l,co]=size(X);
if l==1, X=X'; [l,co]=size(X); end;
if nargin>2,
   if nmin>n, nmin=n; end
   else
   nmin=n;
end;

MM=[];

if rem(n,2)~=1,
 %  error('  N doit etre impair');

% n pair
for c=1:co,

   x=X(:,c);

   for i=1:l
     i1=i-n/2;   i1=max(i1,1);
     i2=i+n/2-1; i2=min(i2,l);
     s=x(i1:i2); smq=sum(isnan(s)); sl=length(s);
     if (smq>nmin | sl<nmin), mm(i)=NaN; else mm(i)=nanmean(s); end;
   end;

  MM=[MM mm'];

end



   else

% n impair
for c=1:co,

   x=X(:,c);

   for i=1:l
     i1=i-(n-1)/2; i1=max(i1,1);
     i2=i+(n-1)/2; i2=min(i2,l);
     s=x(i1:i2); smq=sum(isnan(s)); sl=length(s);
     if (smq>nmin | sl<nmin), mm(i)=NaN; else mm(i)=nanmean(s); end;
   end;

  MM=[MM mm'];

end

end;
