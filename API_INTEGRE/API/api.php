<?php
define("URL", str_replace("index.php","",(isset($_SERVER['HTTPS'])? "https" : "http")."://".$_SERVER['HTTP_HOST'].$_SERVER["PHP_SELF"]));

function getFiches(){
    $pdo=getConnexion();
    $req ="SELECT * from ref_mag_rbi_actu WHERE COD_BRC = S AND COD_MAG LIKE CS%";
    $stmt = $pdo->prepare($req);
    $stmt->execute();
    $all_mag = $stmt->fetchAll(PDO::FETCH_ASSOC);
    for($i=0;$i<count($all_mag);$i++){
        $all_mag[$i]['IMAGE_1'] = "https://outils-casino.fr/fdvpict/".$all_mag[$i]['IMAGE_1'];
    }
    $stmt->closeCursor();
    sendJSON($all_mag);
}
function getFicheByRegion($region){// tri par region
    $pdo=getConnexion();
    $req ="SELECT * from ref_mag_rbi_actu WHERE COD_BRC = S AND COD_MAG LIKE CS% AND WHERE COD_RDR = :COD_RDR";
    $stmt = $pdo->prepare($req);
    $stmt->bindValue(":COD_RDR",$region,PDO::PARAM_STR);
    $stmt->execute();
    $all_mag = $stmt->fetchAll(PDO::FETCH_ASSOC);
    for($i=0;$i<count($all_mag);$i++){
        $all_mag[$i]['IMAGE_1'] = "https://outils-casino.fr/fdvpict/".$all_mag[$i]['IMAGE_1'];
    }
    $stmt->closeCursor();
    sendJSON($all_mag);
}


//permet de chercher un mgasins avec un code CM particulier avec magasin/CM892 par exemple
function getFicheByDE($DE){// Code CM
    $pdo=getConnexion();
    $req ="SELECT fiche_visite_integre.Code_CM
    FROM ref_re3_rbi
    JOIN ref_mag_reg ON ref_re3_rbi.COD_RE3 = ref_mag_reg.COD_RE3
    JOIN ref_mag_rbi_actu ON ref_mag_reg.COD_SRV = ref_mag_rbi_actu.COD_SRV
    JOIN fiche_visite_integre ON ref_mag_rbi_actu.COD_MAG = fiche_visite_integre.Code_CM
    WHERE ref_re3_rbi.LIB_RE3 = :DE;";
    
    $stmt = $pdo->prepare($req);
    $stmt->bindValue(":DE",$DE,PDO::PARAM_STR);
    $stmt->execute();
    $all_mag = $stmt->fetchAll(PDO::FETCH_ASSOC);
    for($i=0;$i<count($all_mag);$i++){
        $all_mag[$i]['IMAGE_1'] = "https://outils-casino.fr/fdvpict/".$all_mag[$i]['IMAGE_1'];
    }
    $stmt->closeCursor();
    sendJSON($all_mag);
}
function getConnexion(){
    return new PDO("mysql:host=localhost;dbname=u133334539_fdvrbismt2;charset=utf8","u133334539_rbi2","$Imon007");
}
function sendJSON($infos){
    header("Acces-Control-Allox-Origin: *");
    header("Content-Type: application/json");
    echo json_encode($infos,JSON_UNESCAPED_UNICODE);
}