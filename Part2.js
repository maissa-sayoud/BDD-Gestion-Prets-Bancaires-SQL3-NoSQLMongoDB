db.prets.insertMany([
  {
    "NumPrêt": 2,
    "montantPrêt": 15000,
    "dateEffet": "2020-02-15",
    "durée": 24,
    "typePrêt": "ANSEJ",
    "tauxIntérêt": 0.03,
    "montantEchéance": 625,
    "NumCompte": 1180005565,
    "compte": {
      "NumCompte": 1180005565,
      "dateOuverture": "2020-01-15",
      "étatCompte": "Actif",
      "Solde": 5000,
      "NumClient": 2
    },
    "client": {
      "NumClient": 2,
      "NomClient": "Karim",
      "TypeClient": "Particulier",
      "AdresseClient": "Birkhadem, Alger",
      "NumTel": "0312345678",
      "Email": "karim@example.com",
      "NumAgence": 105
    },
    "agence": {
      "NumAgence": 105,
      "nomAgence": "Agence principale Sud",
      "adresseAgence": "Kouba, Alger",
      "catégorie": "Principale",
      "NumSucc": 3
    },
    "succursale": {
      "NumSucc": 3,
      "nomSucc": "Succursale Sud",
      "adresseSucc": "Cité 5 Juillet, Kouba, Alger",
      "région": "Sud"
    }
  },
  {
    "NumPrêt": 4,
    "montantPrêt": 8000,
    "dateEffet": "2020-04-20",
    "durée": 12,
    "typePrêt": "Véhicule",
    "tauxIntérêt": 0.04,
    "montantEchéance": 700,
    "NumCompte": 1180005567,
    "compte": {
      "NumCompte": 1180005567,
      "dateOuverture": "2020-03-20",
      "étatCompte": "Actif",
      "Solde": 2000,
      "NumClient": 4
    },
    "client": {
      "NumClient": 4,
      "NomClient": "Salim",
      "TypeClient": "Particulier",
      "AdresseClient": "Chéraga, Alger",
      "NumTel": "0312345678",
      "Email": "salim@example.com",
      "NumAgence": 108
    },
    "agence": {
      "NumAgence": 108,
      "nomAgence": "Agence principale Ouest",
      "adresseAgence": "Bir Mourad Raïs, Alger",
      "catégorie": "Principale",
      "NumSucc": 4
    },
    "succursale": {
      "NumSucc": 4,
      "nomSucc": "Succursale Ouest",
      "adresseSucc": "Cité 1er Novembre, Bir Mourad Raïs, Alger",
      "région": "Ouest"
    }
  },
  {
    "NumPrêt": 5,
    "montantPrêt": 20000,
    "dateEffet": "2020-05-10",
    "durée": 60,
    "typePrêt": "Immobilier",
    "tauxIntérêt": 0.035,
    "montantEchéance": 400,
    "NumCompte": 1180005568,
    "compte": {
      "NumCompte": 1180005568,
      "dateOuverture": "2020-04-10",
      "étatCompte": "Actif",
      "Solde": 10000,
      "NumClient": 5
    },
    "client": {
      "NumClient": 5,
      "NomClient": "Lina",
      "TypeClient": "Particulier",
      "AdresseClient": "Hydra, Alger",
      "NumTel": "0312345678",
      "Email": "lina@example.com",
      "NumAgence": 102
    },
    "agence": {
      "NumAgence": 102,
      "nomAgence": "Agence centrale Est",
      "adresseAgence": "Bab Ezzouar, Alger",
      "catégorie": "Principale",
      "NumSucc": 2
    },
    "succursale": {
      "NumSucc": 2,
      "nomSucc": "Succursale Est",
      "adresseSucc": "Cité 20 Août, Bab Ezzouar, Alger",
      "région": "Est"
    }
  }
]);


db.prets.insertMany([
  {
    "NumPrêt": 6,
    "montantPrêt": 12000,
    "dateEffet": "2020-03-10",
    "durée": 48,
    "typePrêt": "Consommation",
    "tauxIntérêt": 0.06,
    "montantEchéance": 300,
    "NumCompte": 1180005569,
    "compte": {
      "NumCompte": 1180005569,
      "dateOuverture": "2020-02-10",
      "étatCompte": "Actif",
      "Solde": 2000,
      "NumClient": 6
    },
    "client": {
      "NumClient": 6,
      "NomClient": "Hakim",
      "TypeClient": "Particulier",
      "AdresseClient": "Bab El Oued, Alger",
      "NumTel": "0312345678",
      "Email": "hakim@example.com",
      "NumAgence": 102
    },
    "agence": {
      "NumAgence": 102,
      "nomAgence": "Agence centrale Est",
      "adresseAgence": "Bab Ezzouar, Alger",
      "catégorie": "Principale",
      "NumSucc": 2
    },
    "succursale": {
      "NumSucc": 2,
      "nomSucc": "Succursale Est",
      "adresseSucc": "Cité 20 Août, Bab Ezzouar, Alger",
      "région": "Est"
    }
  },
  {
    "NumPrêt": 7,
    "montantPrêt": 18000,
    "dateEffet": "2020-06-05",
    "durée": 36,
    "typePrêt": "Immobilier",
    "tauxIntérêt": 0.04,
    "montantEchéance": 500,
    "NumCompte": 1180005570,
    "compte": {
      "NumCompte": 1180005570,
      "dateOuverture": "2020-05-05",
      "étatCompte": "Actif",
      "Solde": 8000,
      "NumClient": 7
    },
    "client": {
      "NumClient": 7,
      "NomClient": "Nadia",
      "TypeClient": "Particulier",
      "AdresseClient": "Birkhadem, Alger",
      "NumTel": "0312345678",
      "Email": "nadia@example.com",
      "NumAgence": 105
    },
    "agence": {
      "NumAgence": 105,
      "nomAgence": "Agence principale Sud",
      "adresseAgence": "Kouba, Alger",
      "catégorie": "Principale",
      "NumSucc": 3
    },
    "succursale": {
      "NumSucc": 3,
      "nomSucc": "Succursale Sud",
      "adresseSucc": "Cité 5 Juillet, Kouba, Alger",
      "région": "Sud"
    }
  },
  {
    "NumPrêt": 8,
    "montantPrêt": 25000,
    "dateEffet": "2020-07-20",
    "durée": 60,
    "typePrêt": "Immobilier",
    "tauxIntérêt": 0.035,
    "montantEchéance": 600,
    "NumCompte": 1180005571,
    "compte": {
      "NumCompte": 1180005571,
      "dateOuverture": "2020-06-20",
      "étatCompte": "Actif",
      "Solde": 15000,
      "NumClient": 8
    },
    "client": {
      "NumClient": 8,
      "NomClient": "Amine",
      "TypeClient": "Particulier",
      "AdresseClient": "Kouba, Alger",
      "NumTel": "0312345678",
      "Email": "amine@example.com",
      "NumAgence": 108
    },
    "agence": {
      "NumAgence": 108,
      "nomAgence": "Agence principale Ouest",
      "adresseAgence": "Bir Mourad Raïs, Alger",
      "catégorie": "Principale",
      "NumSucc": 4
    },
    "succursale": {
      "NumSucc": 4,
      "nomSucc": "Succursale Ouest",
      "adresseSucc": "Cité 1er Novembre, Bir Mourad Raïs, Alger",
      "région": "Ouest"
    }
  },
  {
    "NumPrêt": 9,
    "montantPrêt": 3000,
    "dateEffet": "2020-08-10",
    "durée": 12,
    "typePrêt": "Consommation",
    "tauxIntérêt": 0.07,
    "montantEchéance": 275,
    "NumCompte": 1180005572,
    "compte": {
      "NumCompte": 1180005572,
      "dateOuverture": "2020-07-10",
      "étatCompte": "Actif",
      "Solde": 500,
      "NumClient": 9
    },
    "client": {
      "NumClient": 9,
      "NomClient": "Sofiane",
      "TypeClient": "Particulier",
      "AdresseClient": "Chéraga, Alger",
      "NumTel": "0312345678",
      "Email": "sofiane@example.com",
      "NumAgence": 101
    },
    "agence": {
      "NumAgence": 101,
      "nomAgence": "Agence principale Nord",
      "adresseAgence": "Hydra, Alger",
      "catégorie": "Principale",
      "NumSucc": 1
    },
    "succursale": {
      "NumSucc": 1,
      "nomSucc": "Succursale Nord",
      "adresseSucc": "10 rue dely brahim, Alger centre",
      "région": "Nord"
    }
  }
]);






ma_base_de_donnes> db.prets.find({"agence.NumAgence": 102})




db.createCollection("Agence-NbPrêts");
{ ok: 1 }
db.prets.aggregate([
    { $group: { _id: "$agence.NumAgence", nbPrêts: { $sum: 1 } } },
    { $sort: { nbPrêts: -1 } },
    { $out: "Agence-NbPrêts" }
]);
db["Agence-NbPrêts"].find();
{
  _id: 102,
  'nbPrêts': 5
}
{
  _id: 108,
  'nbPrêts': 4
}
{
  _id: 105,
  'nbPrêts': 3
}
{
  _id: 101,
  'nbPrêts': 1
}
db.createCollection("Prêt-ANSEJ");
{ ok: 1 }
db["Prêt-ANSEJ"].find(
    { "typePrêt": "ANSEJ" },
    { "NumPrêt": 1, "client.NumClient": 1, "montantPrêt": 1, "dateEffet": 1 }
);
db.prets.find(
    { "client.TypeClient": "Particulier" },
    { "client.NumClient": 1, "client.NomClient": 1, "NumPrêt": 1, "montantPrêt": 1 }
);
{
  _id: ObjectId('66467988e73f7c6b5846b799'),
  'NumPrêt': 2,
  'montantPrêt': 15000,
  client: {
    NumClient: 2,
    NomClient: 'Karim'
  }
}
{
  _id: ObjectId('66467988e73f7c6b5846b79a'),
  'NumPrêt': 4,
  'montantPrêt': 8000,
  client: {
    NumClient: 4,
    NomClient: 'Salim'
  }
}
{
  _id: ObjectId('66467988e73f7c6b5846b79b'),
  'NumPrêt': 5,
  'montantPrêt': 20000,
  client: {
    NumClient: 5,
    NomClient: 'Lina'
  }
}
{
  _id: ObjectId('66467b30e73f7c6b5846b79c'),
  'NumPrêt': 6,
  'montantPrêt': 12000,
  client: {
    NumClient: 6,
    NomClient: 'Hakim'
  }
}
{
  _id: ObjectId('66467b30e73f7c6b5846b79d'),
  'NumPrêt': 7,
  'montantPrêt': 18000,
  client: {
    NumClient: 7,
    NomClient: 'Fatima'
  }
}
{
  _id: ObjectId('66467b30e73f7c6b5846b79e'),
  'NumPrêt': 8,
  'montantPrêt': 25000,
  client: {
    NumClient: 8,
    NomClient: 'Ali'
  }
}
{
  _id: ObjectId('66467b30e73f7c6b5846b79f'),
  'NumPrêt': 9,
  'montantPrêt': 30000,
  client: {
    NumClient: 9,
    NomClient: 'Sara'
  }
}
{
  _id: ObjectId('66467d15e73f7c6b5846b7a0'),
  'NumPrêt': 10,
  'montantPrêt': 20000,
  client: {
    NumClient: 10,
    NomClient: 'Nadia'
  }
}
{
  _id: ObjectId('66467d15e73f7c6b5846b7a1'),
  'NumPrêt': 11,
  'montantPrêt': 25000,
  client: {
    NumClient: 11,
    NomClient: 'Omar'
  }
}
{
  _id: ObjectId('66467d15e73f7c6b5846b7a2'),
  'NumPrêt': 12,
  'montantPrêt': 30000,
  client: {
    NumClient: 12,
    NomClient: 'Karima'
  }
}
{
  _id: ObjectId('66467d76e73f7c6b5846b7a3'),
  'NumPrêt': 13,
  'montantPrêt': 18000,
  client: {
    NumClient: 13,
    NomClient: 'Ahmed'
  }
}
{
  _id: ObjectId('66467d76e73f7c6b5846b7a4'),
  'NumPrêt': 14,
  'montantPrêt': 22000,
  client: {
    NumClient: 14,
    NomClient: 'Sami'
  }
}
{
  _id: ObjectId('66467d76e73f7c6b5846b7a5'),
  'NumPrêt': 15,
  'montantPrêt': 30000,
  client: {
    NumClient: 15,
    NomClient: 'Yasmine'
  }
}
db.prets.updateMany(
    {
        "dateEffet": { $lt: "2021-01-01" },
        "montantEchéance": { $exists: true },
        "Solde": { $gt: 0 }
    },
    {
        $inc: { "montantEchéance": 2000 }
    }
);
db.prets.updateMany(
  {
      "dateEffet": { $lt: "2021-01-01" },
      "montantEchéance": { $exists: true },
      "Solde": { $gt: 0 }
  },
  {
      $inc: { "montantEchéance": 2000 }
  }
);
var mapFunction = function() {
  emit(this.agence.NumAgence, 1);
};
var reduceFunction = function(key, values) {
  return Array.sum(values);
};
db.prets.mapReduce(
  mapFunction,
  reduceFunction,
  { out: "Agence-NbPrêts" }
);
var mapFunction = function() {
  emit(this.agence.NumAgence, 1);
};
var reduceFunction = function(key, values) {
  return Array.sum(values);
};
db.prets.mapReduce(
  mapFunction,
  reduceFunction,
  { out: "Agence-NbPrêts" }
);