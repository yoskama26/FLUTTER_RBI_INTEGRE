<?php
require_once("./api.php");
try{
    if(!empty($_GET['demande'])){
        $url = explode("/", filter_var($_GET['demande'],FILTER_SANITIZE_URL));
        switch($url[0]){
            case "region" : 
                if(empty($url[1])){
                    getFiches();
                } else {
                    getFicheByRegion($url[1]);
                }
            break;
            case "COD_RE3_DE" : 
                if(!empty($url[1])){
                    getFicheByDE($url[1]);
                }else{
                    throw new Exception ("Entrez un numéro d'exploitation.");
                }
            break;
            default : throw new Exception ("vérifiez l'url.");
            

        }
    } else{
        throw new Exception ("Problème de récupération de données.");
    }
} catch(Exception $e){
    $erreur =[
        "message" => $e->getMessage(),
        "code" => $e->getCode()
    ];
    print_r($erreur);
}