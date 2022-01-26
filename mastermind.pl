/*
Projet de Programmation logique 2021/2022 : MasterMind par l'algorithme de Knuth 



********************** POUR TESTER NOTRE PROGRAMME :********************************************************************************
   -ouvrir le repertoire ou se trouve ce fichier.
   -lancer y l'invite de commande.
   -Saisir swipl pour entrer dans l'interpreteur prolog, songer à l'installer au prealable
   -executer notre fichier comme suit : "[projet]."
   -Vous y etes , saisir "masterMind" ou "masterMind()" qui est le point de depart de notre projet
   -Vous pouvez le taper autant que vous le souhaitez pour avoir des cas differents, car la configuration caché est generé 
     aleatoirement lorsque vous lancer le jeu avec la commande precedente.

******************** VOUS POUVEZ EGALEMENT CHANGER LES PARAMETRAGES DU JEU( les 3 premieres lignes de code de notre )***************
  -taille(N) : pour la taille d'une configuration , par defaut ici à 4
  -couleur(L) : la liste des couleurs possibles , ici nous avons opté pour 6 couleurs :
                                                                          r: rouge
                                                                          b:bleue
                                                                          v:vert
                                                                          j:jaune
                                                                          o:orange
                                                                          g:gris
  -nbMax_essaie(N) : pour le nombre maximal de tentatives possibles 

***********COMMANDE POUR LANCER LE PROGRAMME : masterMind. ***************************************************************************
     
  
*/



/*Parametrage  du jeu */ 

/*taille d'une config, liste de couleurs , nombre d'essai max */
taille(4).
couleur([r,j,v,b,o,g]).
nbMax_essaie(12).

/*
Calcul du nombre de noire pour requette
*/
nb_noire(CC,R,NN):-nb_noire(CC,R,0,NN).
nb_noire([],[],N,N).
nb_noire([HC|TC],[HR|TR],NC,NF):-((HR = HC)-> NNC is NC +1, nb_noire(TC,TR,NNC,NF); nb_noire(TC,TR,NC,NF)).

/*
Calcul du nombre de blanc pour requette : difference entre la somme d'occurence minimal de couleur dans CC et R moins le nombre de noire 
*/
nb_blanc(CC,R,NB):-couleur(ListeCouleur),computeLmin(CC,R,ListeCouleur,LminNbColor),sumlist(LminNbColor,N),nb_noire(CC,R,NN), NB is N - NN.

/*
LminNbColor est la liste contenant le minimun du nombre d'apparition pour chaque couleur entre les deux configurations(requette et config cache) 
*/
computeLmin(CC,R,ListeCouleur, LminNbColor):- computeListNbOccur(CC,ListeCouleur,List1),computeListNbOccur(R,ListeCouleur,List2),computeResult(List1,List2,LminNbColor).

/*
computeListNbOccur retourne une liste contenant le nombre d'apparition de chaque element HLC dans  la configuration CONFIG  
*/
  computeListNbOccur(_,[],[]).
  computeListNbOccur(CONFIG,[HLC|TLC],[Nhlc|L]):-count(CONFIG, HLC, Nhlc),computeListNbOccur(CONFIG,TLC,L),!.
    
/*
compter le nb d apparition N d'un element E dans une liste L
*/
    count(L, E, N) :-include(=(E), L, L2), length(L2, N).

/*
computeResult retourne une liste qui prend le min d'apparition de chaque couleur dans deux configurations  
*/
  computeResult([],[], []).
  computeResult([HL1|TL1],[HL2|TL2],[Res|L]):-((HL1 =< HL2 )-> Res = HL1; Res = HL2), computeResult(TL1,TL2,L).

/*
 Generer  une seule configuration au hasard
 */
genereUneConf(L):-taille(N),couleur(LC),genereUneConf(L,N,LC).
genereUneConf([],0,_):-!.
genereUneConf([New|T],N,LC):-random_member(New,LC),NN is N - 1 , genereUneConf(T,NN, LC).

/* 
Generer toutes les configurations possibles pour un jeux de tailles 
*/
genere(L):-taille(N),couleur(LC),length(L,N),genere_AllConf(L,LC).
genere_AllConf([],_):-!.
genere_AllConf([New|T],LC):-member(New,LC), genere_AllConf(T,LC).

 
/*
celui qui va generer les requettes a chaque fois pour essayer de deviner
*/
decodeur(ConfigHist,ConfigCandidat,NewReq):- computelistePoids(ConfigCandidat,Listpoids),minimum(Listpoids,MinPoids),minconfig(ConfigHist,ConfigCandidat,Listpoids,MinPoids,NewReq).

/*
Calcul de  la liste des poids pour toutes les config candidate.
*/
computelistePoids(ConfigCandidat,Listpoids):-genereScore(Lscore),computelistePoids2(ConfigCandidat,Lscore,ConfigCandidat,Listpoids).
computelistePoids2(ConfigCandidat,Lscore, [],[]):-!.
computelistePoids2(ConfigCandidat,Lscore, [Conf|RestConfig],[Poids|Listpoids]):-calculpoids(Conf,ConfigCandidat,Lscore,Poids),computelistePoids2(ConfigCandidat,Lscore, RestConfig,Listpoids).

/*
Calcul du poids d'une configuration c1 pour une base candidat de configuration : 
pour cela il faudra  quele score de c1 avec chacune des conf candidate , puis compter , les occurences de chaque score se repetant, 
et prendre l'occurence la plus grande = poids de c1.
*/
calculpoids(Conf,Candidat,Lscore,Poids):-computelisteOccrScoreCand(Conf,Candidat,Lscore,ListeOccur),maximum(ListeOccur,Poids).


/*
creation de la liste d'occurence d'apparition des differents scores pour chauque config candidate
*/
computelisteOccrScoreCand(Conf,Candidats,Lscore, ListOccur):-listeScoreCand(Candidats,ListeScoresCand,Conf),computeListNbOccur(ListeScoresCand,Lscore,ListOccur) .
listeScoreCand([],[],_).
listeScoreCand([H|RCandidat],[[Nn,Nb]|L],Conf):- nb_noire(Conf,H,Nn),nb_blanc(Conf,H,Nb),listeScoreCand(RCandidat,L,Conf).

maximum(L, Max):-maximum(L,0, Max).
maximum([],Max, Max):-!.
maximum([Head|Tail], Acc, Max):-(Head > Acc ->  Acc2 = Head ; Acc2 = Acc), maximum(Tail, Acc2, Max).

/*
Chercher la conf ayant le poid minimal et n'appartenant pas a l historique des conf deja jouer
*/
minconfig(ConfigHist,[Conf|_],[MinPoids|_],MinPoids,Conf):- not(member(Conf,ConfigHist)),!.
minconfig(ConfigHist,[_|AllConfig],[_|Listpoids],MinPoids,Conf):-minconfig(ConfigHist,AllConfig,Listpoids,MinPoids,Conf).

minimum(L, Min):-minimum(L,5000, Min).
minimum([],Min, Min):-!.
minimum([Head|Tail], Acc, Min):-( (Head  < Acc, Head \= 0) ->   Acc2 = Head ; Acc2 = Acc), minimum(Tail, Acc2, Min).


/*
generation de la liste de tous les scores possibles
*/
 genereScore(Lscore):-taille(N),numlist(0, N, L),findall([Nn,Nb],(genere_AllConf([Nn,Nb],L), Nb \= N, NN is Nn+Nb ,NN =< N , N2 is Nn -Nb ,N2 \= 1 ),Lscore).

/*
 Mis a jour de la base candidates , garder uniquement les config coherente a la requette precedente
*/

majCand([],Req,_,[]).
majCand([H|ConfigCandidat],Req,[Nn,Nb],[H|NewConfigCandidat]):- encodeur(H,Req,NNn,NNb), NNn = Nn, NNb = Nb, !, majCand(ConfigCandidat,Req,[Nn,Nb],NewConfigCandidat).
majCand([H|ConfigCandidat],Req,[Nn,Nb],NewConfigCandidat):-  !, majCand(ConfigCandidat,Req,[Nn,Nb],NewConfigCandidat).
    

/*
celui qui va verifier si la req envoyer par le deco est bonne ou pas en calculant nb noire et blanc et l'envoi au deco
*/
encodeur(CC,Req,Nn,Nb) :- nb_noire(CC,Req,Nn) , nb_blanc(CC,Req,Nb).

/*
Lancer le jeu
*/
masterMind :- couleur(L),genereUneConf(CC),nbMax_essaie(Nmax),format("Config caché : /*  ~w  */  Nombres de tentatives autorisées:  ~w \n", [CC, Nmax]),  findall(X,genere(X),ConfigList), chercheCache(CC,Nmax,ConfigList).

/*
   ICI se ferra notre boucle du jeu , On fait appel au decodeur 
   la premiere fois sans historique et avec comme candidat toutes les config
   tant qu'on a pas trouver ou que le nombre de tentative n est pas finis , decoder , mettre a jour les candidats 
*/
chercheCache(CC,Nmax,ConfigList):- decodeur([],ConfigList,Req), chercheCache(CC,Req,[Req|[]],ConfigList, Nmax).

chercheCache(_,_,_,_,_,0):- writeln("Partie terminer Perdu!! :-( "),!.

chercheCache(CC,Req,ConfigHist,ConfigCandidat,Nmax):-
 encodeur(CC,Req,Nn,Nb),length(Req,NN), NNmax is Nmax - 1, ( ( Nn = NN )-> format("Essaie restant  ~w : ~w  | [~w noires,~w blancs] Yessss!!!! :-)  Trouvéé!!! \n", [NNmax, Req, Nn, Nb]) ; format("Essaie restant  ~w : ~w  | [~w noires,~w blancs] \n", [NNmax, Req, Nn, Nb]),majCand(ConfigCandidat,Req,[Nn,Nb],NewConfigCandidat), decodeur(ConfigHist,NewConfigCandidat,NewReq)  , chercheCache(CC,NewReq,[NewReq|ConfigHist],NewConfigCandidat,NNmax)).




