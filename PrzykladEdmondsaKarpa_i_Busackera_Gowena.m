% Przyk�ad pokazuj�cy schemat dzia�ania algorytmu Edmondsa-Karpa (Forda
% Folkursona z algorytmem BFS do wyznaczenia najkr�tszych �cie�ek opartego na liczbie przeskok�w)

% Przyk�ad pokazuj�cy schemat dzia�ania algorytmu Busackera-Gowena dla sieci z okre�lonymi kosztami
%% Przygotowanie do wykonania skryptu, wst�pne czyszczenie konsoli, zmiennych, otwartych okien
clear; close all; clc;
%% Przypisanie odpowiednich w�a�ciwo�ci sieci
source  = [1 1 2 2 3 3 4 4 5 6 6]; % Pocz�tek kana�u
target_nodes = [2 3 3 7 5 7 3 5 7 1 4]; % Koniec kana�u
names = {'A', 'B', 'C',... % Nazwy w�z��w
    'D','E','s','t'};
throughput = [7 3 4 6 2 9 3 6 8 9 9]; % Wagi w�z��w (przepustowo�� rezydualna) % ew bandwidth nazwa jak dla sieci
cost = [5 6 3 8 8 2 6 8 9 10 5]; % Wagi w�z��w (odleg�o�ci w�z��w)

%% Wizulalizacja sieci rezydualnej 

ResidualGraph = digraph(source,target_nodes,throughput,names); % Utworzenie grafu sieci rezydualnej
ResidualLWidths = 2*ResidualGraph.Edges.Weight/max(ResidualGraph.Edges.Weight); % Szeroko�� kana�u na rysunku
GPlotResidual = plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,'LineWidth',ResidualLWidths); % Rysunek grafu
GPlotResidual.MarkerSize = 7; % Zmiana rozmiaru w�z��w dla przejrzysto�ci rysunku
GPlotResidual.NodeColor='black'; % Zmiana koloru w�z��w dla przejrzysto�ci rysunku
GPlotResidual.EdgeColor='blue'; % Zmiana koloru kana��w dla przejrzysto�ci rysunku

%% Wizualizacja sieci koszt�w
CostGraph = digraph(source,target_nodes,cost,names); % Utworzenie grafu sieci koszt�w
CostLWidths = 2*CostGraph.Edges.Weight/max(CostGraph.Edges.Weight); % Szeroko�� kana�u na rysunku
GPlotCost = plot(CostGraph,'EdgeLabel',CostGraph.Edges.Weight,'LineWidth',CostLWidths); % Rysunek grafu
GPlotCost.MarkerSize = 7; % Zmiana rozmiaru w�z��w dla przejrzysto�ci rysunku
GPlotCost.NodeColor='black'; % Zmiana koloru w�z��w dla przejrzysto�ci rysunku
GPlotCost.EdgeColor='blue'; % Zmiana koloru kana��w dla przejrzysto�ci rysunku
% Mo�emy na wykresie pokaza� wizualnie tak�e stosunek odpowiednich odleg�o�ci mi�dzy w�z�ami
layout(GPlotCost,'force','WeightEffect','direct') ;

%% Przyk�adowe macierze danych dla sieci rezydualnej
% AdjandencyMatrix = full(adjacency(ResidualGraph)) % Macierz s�siedztwa danego grafu
% AdWeMatrix = adjacency(ResidualGraph,'weighted');
% AdjadencyWeightMatrix = full(AdWeMatrix) % Macierz wagowa (s�siedztwa) danego grafu
% IMatrix = incidence(ResidualGraph);
% IncidenceMatrix = full(IMatrix) % Macierz incydencji danego grafu

%% Przyk�ad algorytmu Forda-Folkursona

% Skorzystamy z utworzonych na pocz�tku graf�w i wizualizacji
% W pierwszym kroku algorytmu zerujemy kana�y sieci przep�ywowej, oraz szukamy najkr�tszej �cie�ki rozszerzaj�cej 
% (sieci rezydualnej) ze �r�d�a s do uj�cia t, bior�c pod uwag� jedynie ilo�� kana��w po drodze
FlowGraph = ResidualGraph; FlowGraph.Edges.Weight(:)= 0; NewResidualGraph=ResidualGraph; 
NewResidualLWidths=ResidualLWidths;

% Wyznaczenie najkr�tszej �cie�ki metod� BFS ("niewagow�")
[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualGraph,'s','t','Method','unweighted'); 
disp([ShortestPathOfBuiltGraph,Length,Edges]);
% Oznaczymy znalezion� �cie�k� (na sieci rezydualnej)
GPlotResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',NewResidualLWidths); % Rysunek grafu
GPlotResidual.MarkerSize = 7; % Zmiana rozmiaru w�z��w dla przejrzysto�ci rysunku
GPlotResidual.NodeColor='black'; % Zmiana koloru w�z��w dla przejrzysto�ci rysunku
GPlotResidual.EdgeColor='blue'; % Zmiana koloru kana��w dla przejrzysto�ci rysunku
highlight(GPlotResidual,ShortestPathOfBuiltGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

% Szukamy teraz najmniejszej przepustowo�ci rezydualnej na danej trasie
% Po jej znalezieniu zmniejszamy ka�dy kana� sieci rezydualnej, 
% oraz zwi�kszamy kana� sieci przep�ywowej o dan� warto�� (na danej trasie)
MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl�da sie� przep�ywowa z zaznaczon� �cie�k� przed zwi�kszeniem odpowiednich warto�ci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,...
    'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

StartFlowPathNode = string.empty; EndFlowPathNode = string.empty;
for i=1:(length(ShortestPathOfBuiltGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfBuiltGraph(i); % Startowe w�z�y
    EndFlowPathNode(i)=ShortestPathOfBuiltGraph(i+1); % Ko�cowe w�z�y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl�da nasz otrzymany graf sieci przep�ywowej po pierwszym etapie optymalizacji
plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,...
    'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
% Aby poni�szy graf przedstawia� sie� rezydualn�, musimy usun�� kana�y
% zb�dne(z zerow� przepustowo�ci�) powsta�e w wyniku poprzednich operacji
LWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
L0Widths=find(LWidths==0);LWidths(L0Widths)=mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight); % Szeroko�� kana�u na rysunku

% Tak wygl�da nasz otrzymany graf sieci rezydualnej po pierwszym etapie
% optymalizacji
GPlotResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Nast�pnie wracamy do poszukiwania dalszych �cie�ek rozszerzaj�cych i
% analogicznie wykonujemy dalsze czynno�ci
[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualGraph,'s','t','Method','unweighted'); 
disp([ShortestPathOfBuiltGraph,Length,Edges]);
highlight(GPlotResidual,ShortestPathOfBuiltGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');
MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl�da sie� przep�ywowa z zaznaczon� �ci�k� przed zwi�kszeniem odpowiednich warto�ci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
disp(GPlotFlow);
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfBuiltGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfBuiltGraph(i); % Startowe w�z�y
    EndFlowPathNode(i)=ShortestPathOfBuiltGraph(i+1); % Ko�cowe w�z�y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl�da nasz otrzymany graf sieci przep�ywowej po drugim etapie
% optymalizacji
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% A aby poni�szy graf przedstawia� sie� rezydualn�, musimy usun�� kana�y
% zb�dne(z zerow� przepustowo�ci�) powsta�e w wyniku poprzednich operacji
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
ResidualL0Widths=NewResidualLWidths==0;
NewResidualLWidths(ResidualL0Widths)= mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight); % Szeroko�� kana�u na rysunku

% Tak wygl�da nasz otrzymany graf sieci rezydualnej po drugim etapie
% optymalizacji
GPlotResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Analogicznie w etapie trzecim:
[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualGraph,'s','t','Method','unweighted');
disp([ShortestPathOfBuiltGraph,Length,Edges]);
highlight(GPlotResidual,ShortestPathOfBuiltGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');
MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl�da sie� przep�ywowa z zaznaczon� �cie�k� przed zwi�kszeniem odpowiednich warto�ci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfBuiltGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfBuiltGraph(i); % Startowe w�z�y
    EndFlowPathNode(i)=ShortestPathOfBuiltGraph(i+1); % Ko�cowe w�z�y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl�da nasz otrzymany graf sieci przep�ywowej po trzecim etapie
% optymalizacji
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red',...
    'EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% A aby poni�szy graf przedstawia� sie� rezydualn�, musimy usun�� kana�y
% zb�dne(z zerow� przepustowo�ci�) powsta�e w wyniku poprzednich operacji
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
ResidualL0Widths=NewResidualLWidths==0;
NewResidualLWidths(ResidualL0Widths)= mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight); % Szeroko�� kana�u na rysunku

% Tak wygl�da nasz otrzymany graf sieci rezydualnej po trzecim etapie
% optymalizacji
GPlotResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Etap czwarty ...
[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualGraph,'s','t','Method','unweighted');
disp([ShortestPathOfBuiltGraph,Length,Edges]);
highlight(GPlotResidual,ShortestPathOfBuiltGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');
MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl�da sie� przep�ywowa z zaznaczon� �ci�zk� przed zwi�kszeniem odpowiednich warto�ci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfBuiltGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfBuiltGraph(i); % Startowe w�z�y
    EndFlowPathNode(i)=ShortestPathOfBuiltGraph(i+1); % Ko�cowe w�z�y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl�da nasz otrzymany graf sieci przep�ywowej po czwartym etapie
% optymalizacji
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% A aby poni�szy graf przedstawia� sie� rezydualn�, musimy usun�� kana�y
% zb�dne(z zerow� przepustowo�ci�) powsta�e w wyniku poprzednich operacji
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
ResidualL0Widths=NewResidualLWidths==0; NewResidualLWidths(ResidualL0Widths)= mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight); 
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight); % Szeroko�� kana�u na rysunku

% Tak wygl�da nasz otrzymany graf sieci rezydualnej po czwartym etapie
% optymalizacji
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Etap pi�ty
[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualGraph,'s','t','Method','unweighted');
disp([ShortestPathOfBuiltGraph,Length,Edges]);
% Doszli�my do etapu, w kt�rym nie mo�emy znale�� �cie�ki rozszerzaj�cej.
% Przep�yw nie mo�e by� ju� bardziej zwi�kszony, a wi�c ostatecznie: graf
% sieci przep�ywowej wygl�da w nast�puj�cy spos�b (po usuni�ciu kana��w wyschni�tych):
numbers = find(FlowGraph.Edges.Weight==0);
FlowGraph=rmedge(FlowGraph,numbers);
plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red',...
    'EdgeColor','green','MarkerSize',7,'LineWidth',2);
disp('Network has been fully optimised.');


%% Przyk�ad algorytmu Busackera-Gowena dla sieci z okre�lonymi kosztami
% Skorzystamy z utworzonych na pocz�tku graf�w i wizualizacji
% W pierwszym kroku algorytmu zerujemy kana�y sieci przep�ywowej, oraz szukamy najkr�tszej �cie�ki rozszerzaj�cej 
% (w grafie z wagami okre�laj�cymi odpowiednie koszty) ze �r�d�a s do uj�cia t, bior�c pod uwag� koszty/odleg�o�ci 
FlowGraph = ResidualGraph; FlowGraph.Edges.Weight(:)= 0; NewResidualGraph=ResidualGraph; 
NewResidualLWidths=ResidualLWidths;

% Wyznaczenie najkr�tszej �cie�ki metod� Djikstry (dla �uk�w okre�lonych dodatnio)
[ShortestPathOfCostGraph,Length,Edges] = shortestpath(CostGraph,'s','t','Method','positive');
disp([ShortestPathOfCostGraph,Length,Edges]);
GPlotCost = plot(CostGraph,'EdgeLabel',CostGraph.Edges.Weight,'LineWidth',CostLWidths); % Rysunek grafu
GPlotCost.MarkerSize = 7; % Zmiana rozmiaru w�z��w dla przejrzysto�ci rysunku
GPlotCost.NodeColor='black'; % Zmiana koloru w�z��w dla przejrzysto�ci rysunku
GPlotCost.EdgeColor='blue'; % Zmiana koloru kana��w dla przejrzysto�ci rysunku
layout(GPlotCost,'force','WeightEffect','direct') ;
highlight(GPlotCost,ShortestPathOfCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

% Poka�emy wyznaczon� odpowiadaj�c� najkr�tszej �cie�ce z sieci koszt�w �cie�k� w sieci rezydualnej)
GPlotResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',ResidualLWidths); % Rysunek grafu
GPlotResidual.MarkerSize = 7; % Zmiana rozmiaru w�z��w dla przejrzysto�ci rysunku
GPlotResidual.NodeColor='black'; % Zmiana koloru w�z��w dla przejrzysto�ci rysunku
GPlotResidual.EdgeColor='blue'; % Zmiana koloru kana��w dla przejrzysto�ci rysunku
highlight(GPlotResidual,ShortestPathOfCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

% Szukamy teraz najmniejszej przepustowo�ci rezydualnej na danej trasie
% Po jej znalezieniu zmniejszamy ka�dy kana� sieci rezydualnej, 
% oraz zwi�kszamy kana� sieci przep�ywowej o dan� warto�� (na danej trasie)
MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl�da sie� przep�ywowa z zaznaczon� �cie�k� przed zwi�kszeniem odpowiednich warto�ci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,...
    'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfCostGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfCostGraph(i); % Startowe w�z�y
    EndFlowPathNode(i)=ShortestPathOfCostGraph(i+1); % Ko�cowe w�z�y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl�da nasz otrzymany graf sieci przep�ywowej po pierwszym etapie optymalizacji
plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,...
    'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
% Aby poni�szy graf przedstawia� sie� rezydualn�, musimy usun�� kana�y
% zb�dne(z zerow� przepustowo�ci�) powsta�e w wyniku poprzednich operacji
ResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
ResidualL0Widths=ResidualLWidths==0;
ResidualLWidths(ResidualL0Widths) = mean(ResidualGraph.Edges.Weight)/sum(ResidualGraph.Edges.Weight);
plot(ResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Musimy uwzgl�dni� tak�e, �e przy wyznaczone p�niej najkr�tsze trasy nie mog� zawiera� 
% kana��w uschni�tych grafu sieci rezydualnej. Dla uproszczenia utworzymy pomocniczy graf
% na podstawie grafu koszt�w, jednak bez wspomnianych kana��w. Nast�pnie za jednym
% razem usuniemy wi�c odpowiednie kana�y w grafie rezydualnym i pomocniczym
SmallerCostGraph = digraph(source,target_nodes,cost,names); % Utworzenie pomocniczego grafu (koszt�w)

numbers = find(ResidualGraph.Edges.Weight==0);
ResidualGraph=rmedge(ResidualGraph,numbers);
SmallerCostGraph=rmedge(SmallerCostGraph,numbers);
% (Musimy tak�e usun�� wszystkie parametry danej kraw�dzi z odpowiednich list)
ResidualLWidths = 2*ResidualGraph.Edges.Weight/max(ResidualGraph.Edges.Weight); % Szeroko�� kana�u na rysunku
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight); % Szeroko�� kana�u na rysunku

% Tak wygl�da nasz otrzymany graf sieci rezydualnej po pierwszym etapie
% optymalizacji
plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);
% Tak wygl�da nasz otrzymany graf pomocniczy po pierwszym etapie
% optymalizacji
plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,...
    'LineWidth',SmallerCostLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Nast�pnie wracamy do poszukiwania dalszych �cie�ek rozszerzaj�cych i
% analogicznie wykonujemy dalsze czynno�ci, jak w poprzednim etapie
% algorytmu, jednak tym razem korzystamy z grafu pomocniczego do wyznaczenia �cie�ek
[ShortestPathOfSmallerCostGraph,Length,Edges] = shortestpath(SmallerCostGraph,'s','t','Method','positive');
disp([ShortestPathOfSmallerCostGraph,Length,Edges]);

GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,'LineWidth',SmallerCostLWidths); % Rysunek grafu
GPlotSmallerCost.MarkerSize = 7; % Zmiana rozmiaru w�z��w dla przejrzysto�ci rysunku
GPlotSmallerCost.NodeColor='black'; % Zmiana koloru w�z��w dla przejrzysto�ci rysunku
GPlotSmallerCost.EdgeColor='blue'; % Zmiana koloru kana��w dla przejrzysto�ci rysunku
highlight(GPlotSmallerCost,ShortestPathOfSmallerCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

MinimumResidualCapacity = min(ResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
ResidualGraph.Edges.Weight(Edges)= ResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl�da sie� przep�ywowa z zaznaczon� �cie�k� przed zwi�kszeniem odpowiednich warto�ci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfSmallerCostGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i); % Startowe w�z�y
    EndFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i+1); % Ko�cowe w�z�y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl�da nasz otrzymany graf sieci przep�ywowej po drugim etapie
% optymalizacji
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% A aby poni�szy graf przedstawia� sie� rezydualn�, musimy usun�� kana�y
% zb�dne(z zerow� przepustowo�ci�) powsta�e w wyniku poprzednich operacji
ResidualL0Widths = ResidualLWidths==0; 
ResidualLWidths(ResidualL0Widths)= mean(ResidualGraph.Edges.Weight)/sum(ResidualGraph.Edges.Weight);
plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,'LineWidth',...
    ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(ResidualGraph.Edges.Weight==0);
ResidualGraph=rmedge(ResidualGraph,numbers);
SmallerCostGraph=rmedge(SmallerCostGraph,numbers);
% (Musimy tak�e usun�� wszystkie parametry danej kraw�dzi z odpowiednich list)
ResidualLWidths = 2*ResidualGraph.Edges.Weight/max(ResidualGraph.Edges.Weight); % Szeroko�� kana�u na rysunku
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight); % Szeroko�� kana�u na rysunku

% Tak wygl�da nasz otrzymany graf sieci rezydualnej po drugim etapie optymalizacji
plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);
% Tak wygl�da nasz otrzymany graf pomocniczy po drugim etapie optymalizacji
plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,...
    'LineWidth',SmallerCostLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Analogicznie w etapie trzecim:
[ShortestPathOfSmallerCostGraph,Length,Edges] = shortestpath(SmallerCostGraph,'s','t','Method','positive');
disp([ShortestPathOfSmallerCostGraph,Length,Edges]);

GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,'LineWidth',SmallerCostLWidths); % Rysunek grafu
GPlotSmallerCost.MarkerSize = 7; % Zmiana rozmiaru w�z��w dla przejrzysto�ci rysunku
GPlotSmallerCost.NodeColor='black'; % Zmiana koloru w�z��w dla przejrzysto�ci rysunku
GPlotSmallerCost.EdgeColor='blue'; % Zmiana koloru kana��w dla przejrzysto�ci rysunku
highlight(GPlotSmallerCost,ShortestPathOfSmallerCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

MinimumResidualCapacity = min(ResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
ResidualGraph.Edges.Weight(Edges)= ResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl�da sie� przep�ywowa z zaznaczon� �ci�k� przed zwi�kszeniem odpowiednich warto�ci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfSmallerCostGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i); % Startowe w�z�y
    EndFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i+1); % Ko�cowe w�z�y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl�da nasz otrzymany graf sieci przep�ywowej po trzecim etapie
% optymalizacji
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red',...
    'EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% A aby poni�szy graf przedstawia� sie� rezydualn�, musimy usun�� kana�y
% zb�dne(z zerow� przepustowo�ci�) powsta�e w wyniku poprzednich operacji
ResidualL0Widths=ResidualLWidths==0;
ResidualLWidths(ResidualL0Widths)= mean(ResidualGraph.Edges.Weight)/sum(ResidualGraph.Edges.Weight);
plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(ResidualGraph.Edges.Weight==0);
ResidualGraph=rmedge(ResidualGraph,numbers);
SmallerCostGraph=rmedge(SmallerCostGraph,numbers);
% (Musimy tak�e usun�� wszystkie parametry danej kraw�dzi z odpowiednich list)
ResidualLWidths = 2*ResidualGraph.Edges.Weight/max(ResidualGraph.Edges.Weight); % Szeroko�� kana�u na rysunku
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight); % Szeroko�� kana�u na rysunku

% Tak wygl�da nasz otrzymany graf sieci rezydualnej po trzecim etapie
% optymalizacji
GPlotResidual = plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);
disp(GPlotResidual);
% layout(GPlotResidual,'force','WeightEffect','direct') 

% Etap czwarty ...
[ShortestPathOfSmallerCostGraph,Length,Edges] = shortestpath(SmallerCostGraph,'s','t','Method','positive');
disp([ShortestPathOfSmallerCostGraph,Length,Edges]);

GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,'LineWidth',SmallerCostLWidths); % Rysunek grafu
GPlotSmallerCost.MarkerSize = 7; % Zmiana rozmiaru w�z��w dla przejrzysto�ci rysunku
GPlotSmallerCost.NodeColor='black'; % Zmiana koloru w�z��w dla przejrzysto�ci rysunku
GPlotSmallerCost.EdgeColor='blue'; % Zmiana koloru kana��w dla przejrzysto�ci rysunku
highlight(GPlotSmallerCost,ShortestPathOfSmallerCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

MinimumResidualCapacity = min(ResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
ResidualGraph.Edges.Weight(Edges)= ResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl�da sie� przep�ywowa z zaznaczon� �ci�zk� przed zwi�kszeniem odpowiednich warto�ci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfSmallerCostGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i); % Startowe w�z�y
    EndFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i+1); % Ko�cowe w�z�y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl�da nasz otrzymany graf sieci przep�ywowej po czwartym etapie
% optymalizacji
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% A aby poni�szy graf przedstawia� sie� rezydualn�, musimy usun�� kana�y
% zb�dne(z zerow� przepustowo�ci�) powsta�e w wyniku poprzednich operacji
ResidualLWidths = 2*ResidualGraph.Edges.Weight/max(ResidualGraph.Edges.Weight);
ResidualL0Widths=ResidualLWidths==0;ResidualLWidths(ResidualL0Widths)= mean(ResidualGraph.Edges.Weight)/sum(ResidualGraph.Edges.Weight);
plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(ResidualGraph.Edges.Weight==0);
ResidualGraph=rmedge(ResidualGraph,numbers);
SmallerCostGraph=rmedge(SmallerCostGraph,numbers);
% (Musimy tak�e usun�� wszystkie parametry danej kraw�dzi z odpowiednich list)
ResidualLWidths = 2*ResidualGraph.Edges.Weight/max(ResidualGraph.Edges.Weight); % Szeroko�� kana�u na rysunku
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight); % Szeroko�� kana�u na rysunku

% Tak wygl�da nasz otrzymany graf sieci rezydualnej po czwartym etapie
% optymalizacji
plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Etap pi�ty ...
[ShortestPathOfSmallerCostGraph,Length,Edges] = shortestpath(SmallerCostGraph,'s','t','Method','positive');
disp([ShortestPathOfSmallerCostGraph,Length,Edges]);

GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,'LineWidth',SmallerCostLWidths); % Rysunek grafu
GPlotSmallerCost.MarkerSize = 7; % Zmiana rozmiaru w�z��w dla przejrzysto�ci rysunku
GPlotSmallerCost.NodeColor='black'; % Zmiana koloru w�z��w dla przejrzysto�ci rysunku
GPlotSmallerCost.EdgeColor='blue'; % Zmiana koloru kana��w dla przejrzysto�ci rysunku
highlight(GPlotSmallerCost,ShortestPathOfSmallerCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

MinimumResidualCapacity = min(ResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
ResidualGraph.Edges.Weight(Edges)= ResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl�da sie� przep�ywowa z zaznaczon� �ci�zk� przed zwi�kszeniem odpowiednich warto�ci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfSmallerCostGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i); % Startowe w�z�y
    EndFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i+1); % Ko�cowe w�z�y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl�da nasz otrzymany graf sieci przep�ywowej po pi�tym etapie
% optymalizacji
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% A aby poni�szy graf przedstawia� sie� rezydualn�, musimy usun�� kana�y
% zb�dne(z zerow� przepustowo�ci�) powsta�e w wyniku poprzednich operacji
ResidualLWidths = 2*ResidualGraph.Edges.Weight/max(ResidualGraph.Edges.Weight);
ResidualL0Widths=find(ResidualLWidths==0);ResidualLWidths(ResidualL0Widths)= mean(ResidualGraph.Edges.Weight)/sum(ResidualGraph.Edges.Weight);
plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(ResidualGraph.Edges.Weight==0);
ResidualGraph=rmedge(ResidualGraph,numbers);
SmallerCostGraph=rmedge(SmallerCostGraph,numbers);
% (Musimy tak�e usun�� wszystkie parametry danej kraw�dzi z odpowiednich list)
ResidualLWidths = 2*ResidualGraph.Edges.Weight/max(ResidualGraph.Edges.Weight); % Szeroko�� kana�u na rysunku
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight); % Szeroko�� kana�u na rysunku

% Tak wygl�da nasz otrzymany graf sieci rezydualnej po pi�tym etapie
% optymalizacji
GPlotResidual = plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Etap sz�sty
[ShortestPathOfSmallerCostGraph,Length,Edges] = shortestpath(SmallerCostGraph,'s','t','Method','positive');
disp([ShortestPathOfSmallerCostGraph,Length,Edges]);
% Doszli�my do etapu, w kt�rym nie mo�emy znale�� �cie�ki rozszerzaj�cej.
% Przep�yw nie mo�e by� ju� bardziej zwi�kszony, a wi�c ostatecznie graf
% sieci przep�ywowej wygl�da w nast�puj�cy spos�b (po usuni�ciu kana��w wyschni�tych):
numbers = find(FlowGraph.Edges.Weight==0);
FlowGraph=rmedge(FlowGraph,numbers);
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red',...
    'EdgeColor','green','MarkerSize',7,'LineWidth',2);
disp('Network has been fully optimised.');
