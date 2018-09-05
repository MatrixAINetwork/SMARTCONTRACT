/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.2;
/*'pragma' indique au compileur dans quelle version de Solidity ce code est écrit */
contract storer {
/*'contract' indique le début du contrat a proprement parler 'contract' est similaire
à 'class' dans d'autres langages (class variables, inheritance, etc.)*/
address public owner;
string public log;
/* 29979245621189875516790
function storer() {
    owner = msg.sender ;
}
/* 'storer' est une fonction un peu particulière, il s'agit du constructeur du contrat.
Cette fonction s'exécute une seule fois au moment de la création du contrat.
La création du contrat est une transaction et comme toute transaction elle est
représentée en Solidity par "msg", "msg.sender" correspond  à l'adresse qui
émet cette transaction.  
A la création du contrat la variable owner reçoit l'adresse qui a déployé le
contrat */
modifier onlyOwner {
        if (msg.sender != owner)
            throw;
        _;
    }
/* le 'modifier' permet de poser des conditions à l'exécution des fonctions.
Ici, 'onlyOwner' sera ajouté à la syntaxe des fonctions que l'on
veut réserver au 'owner'. Le modifier teste la condion msg.sender != owner
si le requêteur de la fonction n'est pas le owner alors l'exécution
s'interrompt, c'est le sens du 'throw'; s'il s'agit bien du owner alors
la fonction s'exécute. Notez le '_' underscore après le test, il signifie
à la fonction de continuer son exécution.*/    
function store(string _log) onlyOwner() {
    log = _log;
}
/*La fonction 'store' reçoit une chaîne de caractères qu'elle associe à une
variable d'état '_log'. Cette fonction n'est utilisable que par l'adresse qui
est 'owner', si c'est bien cette adresse qui fait la requête alors la variable
'log' devient '_log'.*/
function kill() onlyOwner() {
  selfdestruct(owner); }
/* Cette dernière fonction permet de "nettoyer" la blockchain en supprimant le
contrat. Il est important de la faire figurer pour libérer de l'espace sur
la blockchain mais aussi pour supprimer un contrat buggé. En précisant une
adresse selfdestruct(address), tous les ethers stockés par le contrat y sont
envoyés. Attention si une transaction envoie des ethers à un contrat qui s'est
"selfdestruct" ces ethers seront perdus*/
}