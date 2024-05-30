db.prets.insertMany([
  {
    "NumPr�t": 2,
    "montantPr�t": 15000,
    "dateEffet": "2020-02-15",
    "dur�e": 24,
    "typePr�t": "ANSEJ",
    "tauxInt�r�t": 0.03,
    "montantEch�ance": 625,
    "NumCompte": 1180005565,
    "compte": {
      "NumCompte": 1180005565,
      "dateOuverture": "2020-01-15",
      "�tatCompte": "Actif",
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
      "cat�gorie": "Principale",
      "NumSucc": 3
    },
    "succursale": {
      "NumSucc": 3,
      "nomSucc": "Succursale Sud",
      "adresseSucc": "Cit� 5 Juillet, Kouba, Alger",
      "r�gion": "Sud"
    }
  },
  {
    "NumPr�t": 4,
    "montantPr�t": 8000,
    "dateEffet": "2020-04-20",
    "dur�e": 12,
    "typePr�t": "V�hicule",
    "tauxInt�r�t": 0.04,
    "montantEch�ance": 700,
    "NumCompte": 1180005567,
    "compte": {
      "NumCompte": 1180005567,
      "dateOuverture": "2020-03-20",
      "�tatCompte": "Actif",
      "Solde": 2000,
      "NumClient": 4
    },
    "client": {
      "NumClient": 4,
      "NomClient": "Salim",
      "TypeClient": "Particulier",
      "AdresseClient": "Ch�raga, Alger",
      "NumTel": "0312345678",
      "Email": "salim@example.com",
      "NumAgence": 108
    },
    "agence": {
      "NumAgence": 108,
      "nomAgence": "Agence principale Ouest",
      "adresseAgence": "Bir Mourad Ra�s, Alger",
      "cat�gorie": "Principale",
      "NumSucc": 4
    },
    "succursale": {
      "NumSucc": 4,
      "nomSucc": "Succursale Ouest",
      "adresseSucc": "Cit� 1er Novembre, Bir Mourad Ra�s, Alger",
      "r�gion": "Ouest"
    }
  },
  {
    "NumPr�t": 5,
    "montantPr�t": 20000,
    "dateEffet": "2020-05-10",
    "dur�e": 60,
    "typePr�t": "Immobilier",
    "tauxInt�r�t": 0.035,
    "montantEch�ance": 400,
    "NumCompte": 1180005568,
    "compte": {
      "NumCompte": 1180005568,
      "dateOuverture": "2020-04-10",
      "�tatCompte": "Actif",
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
      "cat�gorie": "Principale",
      "NumSucc": 2
    },
    "succursale": {
      "NumSucc": 2,
      "nomSucc": "Succursale Est",
      "adresseSucc": "Cit� 20 Ao�t, Bab Ezzouar, Alger",
      "r�gion": "Est"
    }
  }
]);


db.prets.insertMany([
  {
    "NumPr�t": 6,
    "montantPr�t": 12000,
    "dateEffet": "2020-03-10",
    "dur�e": 48,
    "typePr�t": "Consommation",
    "tauxInt�r�t": 0.06,
    "montantEch�ance": 300,
    "NumCompte": 1180005569,
    "compte": {
      "NumCompte": 1180005569,
      "dateOuverture": "2020-02-10",
      "�tatCompte": "Actif",
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
      "cat�gorie": "Principale",
      "NumSucc": 2
    },
    "succursale": {
      "NumSucc": 2,
      "nomSucc": "Succursale Est",
      "adresseSucc": "Cit� 20 Ao�t, Bab Ezzouar, Alger",
      "r�gion": "Est"
    }
  },
  {
    "NumPr�t": 7,
    "montantPr�t": 18000,
    "dateEffet": "2020-06-05",
    "dur�e": 36,
    "typePr�t": "Immobilier",
    "tauxInt�r�t": 0.04,
    "montantEch�ance": 500,
    "NumCompte": 1180005570,
    "compte": {
      "NumCompte": 1180005570,
      "dateOuverture": "2020-05-05",
      "�tatCompte": "Actif",
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
      "cat�gorie": "Principale",
      "NumSucc": 3
    },
    "succursale": {
      "NumSucc": 3,
      "nomSucc": "Succursale Sud",
      "adresseSucc": "Cit� 5 Juillet, Kouba, Alger",
      "r�gion": "Sud"
    }
  },
  {
    "NumPr�t": 8,
    "montantPr�t": 25000,
    "dateEffet": "2020-07-20",
    "dur�e": 60,
    "typePr�t": "Immobilier",
    "tauxInt�r�t": 0.035,
    "montantEch�ance": 600,
    "NumCompte": 1180005571,
    "compte": {
      "NumCompte": 1180005571,
      "dateOuverture": "2020-06-20",
      "�tatCompte": "Actif",
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
      "adresseAgence": "Bir Mourad Ra�s, Alger",
      "cat�gorie": "Principale",
      "NumSucc": 4
    },
    "succursale": {
      "NumSucc": 4,
      "nomSucc": "Succursale Ouest",
      "adresseSucc": "Cit� 1er Novembre, Bir Mourad Ra�s, Alger",
      "r�gion": "Ouest"
    }
  },
  {
    "NumPr�t": 9,
    "montantPr�t": 3000,
    "dateEffet": "2020-08-10",
    "dur�e": 12,
    "typePr�t": "Consommation",
    "tauxInt�r�t": 0.07,
    "montantEch�ance": 275,
    "NumCompte": 1180005572,
    "compte": {
      "NumCompte": 1180005572,
      "dateOuverture": "2020-07-10",
      "�tatCompte": "Actif",
      "Solde": 500,
      "NumClient": 9
    },
    "client": {
      "NumClient": 9,
      "NomClient": "Sofiane",
      "TypeClient": "Particulier",
      "AdresseClient": "Ch�raga, Alger",
      "NumTel": "0312345678",
      "Email": "sofiane@example.com",
      "NumAgence": 101
    },
    "agence": {
      "NumAgence": 101,
      "nomAgence": "Agence principale Nord",
      "adresseAgence": "Hydra, Alger",
      "cat�gorie": "Principale",
      "NumSucc": 1
    },
    "succursale": {
      "NumSucc": 1,
      "nomSucc": "Succursale Nord",
      "adresseSucc": "10 rue dely brahim, Alger centre",
      "r�gion": "Nord"
    }
  }
]);






ma_base_de_donnes> db.prets.find({"agence.NumAgence": 102})




db.createCollection("Agence-NbPr�ts");
{ ok: 1 }
db.prets.aggregate([
    { $group: { _id: "$agence.NumAgence", nbPr�ts: { $sum: 1 } } },
    { $sort: { nbPr�ts: -1 } },
    { $out: "Agence-NbPr�ts" }
]);
db["Agence-NbPr�ts"].find();
{
  _id: 102,
  'nbPr�ts': 5
}
{
  _id: 108,
  'nbPr�ts': 4
}
{
  _id: 105,
  'nbPr�ts': 3
}
{
  _id: 101,
  'nbPr�ts': 1
}
db.createCollection("Pr�t-ANSEJ");
{ ok: 1 }
db["Pr�t-ANSEJ"].find(
    { "typePr�t": "ANSEJ" },
    { "NumPr�t": 1, "client.NumClient": 1, "montantPr�t": 1, "dateEffet": 1 }
);
db.prets.find(
    { "client.TypeClient": "Particulier" },
    { "client.NumClient": 1, "client.NomClient": 1, "NumPr�t": 1, "montantPr�t": 1 }
);
{
  _id: ObjectId('66467988e73f7c6b5846b799'),
  'NumPr�t': 2,
  'montantPr�t': 15000,
  client: {
    NumClient: 2,
    NomClient: 'Karim'
  }
}
{
  _id: ObjectId('66467988e73f7c6b5846b79a'),
  'NumPr�t': 4,
  'montantPr�t': 8000,
  client: {
    NumClient: 4,
    NomClient: 'Salim'
  }
}
{
  _id: ObjectId('66467988e73f7c6b5846b79b'),
  'NumPr�t': 5,
  'montantPr�t': 20000,
  client: {
    NumClient: 5,
    NomClient: 'Lina'
  }
}
{
  _id: ObjectId('66467b30e73f7c6b5846b79c'),
  'NumPr�t': 6,
  'montantPr�t': 12000,
  client: {
    NumClient: 6,
    NomClient: 'Hakim'
  }
}
{
  _id: ObjectId('66467b30e73f7c6b5846b79d'),
  'NumPr�t': 7,
  'montantPr�t': 18000,
  client: {
    NumClient: 7,
    NomClient: 'Fatima'
  }
}
{
  _id: ObjectId('66467b30e73f7c6b5846b79e'),
  'NumPr�t': 8,
  'montantPr�t': 25000,
  client: {
    NumClient: 8,
    NomClient: 'Ali'
  }
}
{
  _id: ObjectId('66467b30e73f7c6b5846b79f'),
  'NumPr�t': 9,
  'montantPr�t': 30000,
  client: {
    NumClient: 9,
    NomClient: 'Sara'
  }
}
{
  _id: ObjectId('66467d15e73f7c6b5846b7a0'),
  'NumPr�t': 10,
  'montantPr�t': 20000,
  client: {
    NumClient: 10,
    NomClient: 'Nadia'
  }
}
{
  _id: ObjectId('66467d15e73f7c6b5846b7a1'),
  'NumPr�t': 11,
  'montantPr�t': 25000,
  client: {
    NumClient: 11,
    NomClient: 'Omar'
  }
}
{
  _id: ObjectId('66467d15e73f7c6b5846b7a2'),
  'NumPr�t': 12,
  'montantPr�t': 30000,
  client: {
    NumClient: 12,
    NomClient: 'Karima'
  }
}
{
  _id: ObjectId('66467d76e73f7c6b5846b7a3'),
  'NumPr�t': 13,
  'montantPr�t': 18000,
  client: {
    NumClient: 13,
    NomClient: 'Ahmed'
  }
}
{
  _id: ObjectId('66467d76e73f7c6b5846b7a4'),
  'NumPr�t': 14,
  'montantPr�t': 22000,
  client: {
    NumClient: 14,
    NomClient: 'Sami'
  }
}
{
  _id: ObjectId('66467d76e73f7c6b5846b7a5'),
  'NumPr�t': 15,
  'montantPr�t': 30000,
  client: {
    NumClient: 15,
    NomClient: 'Yasmine'
  }
}
db.prets.updateMany(
    {
        "dateEffet": { $lt: "2021-01-01" },
        "montantEch�ance": { $exists: true },
        "Solde": { $gt: 0 }
    },
    {
        $inc: { "montantEch�ance": 2000 }
    }
);
db.prets.updateMany(
  {
      "dateEffet": { $lt: "2021-01-01" },
      "montantEch�ance": { $exists: true },
      "Solde": { $gt: 0 }
  },
  {
      $inc: { "montantEch�ance": 2000 }
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
  { out: "Agence-NbPr�ts" }
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
  { out: "Agence-NbPr�ts" }
);