# 🎬 Filmothèque — Guide d'installation Supabase

## Pourquoi Supabase ?

- **Gratuit** : le plan Free suffit largement (500 Mo, 50 000 requêtes/mois)
- **Zéro code serveur** : PostgreSQL + API REST générée automatiquement
- **Temps d'installation** : ~15 minutes
- **Multi-utilisateurs** : toi + tes proches, chacun avec son propre "vu/pas vu"

---

## ÉTAPE 1 — Créer ton projet Supabase (5 min)

1. Va sur **https://supabase.com** et crée un compte (GitHub ou email)
2. Clique **"New Project"**
3. Remplis :
   - **Name** : `filmotheque`
   - **Database Password** : choisis un mot de passe fort (note-le)
   - **Region** : `West EU (Ireland)` (le plus proche de la France)
4. Clique **"Create new project"** → attends ~2 min que ça se configure

## ÉTAPE 2 — Créer les tables (3 min)

1. Dans ton projet Supabase, va dans **SQL Editor** (menu de gauche)
2. Clique **"New query"**
3. Copie-colle **tout le contenu** du fichier `supabase_migration.sql` (fourni)
4. Clique **"Run"** (▶)
5. Tu devrais voir `Success. No rows returned` — c'est normal, les tables sont créées

## ÉTAPE 3 — Importer les données (3 min)

1. Toujours dans **SQL Editor**, crée une nouvelle query
2. Copie-colle **tout le contenu** du fichier `supabase_data.sql` (fourni)
3. Clique **"Run"** (▶)
4. Vérifie dans **Table Editor** (menu gauche) que tu vois tes 69 films

## ÉTAPE 4 — Récupérer tes clés (1 min)

1. Va dans **Settings** → **API** (menu de gauche)
2. Note ces 2 valeurs :
   - **Project URL** : `https://xxxxx.supabase.co`
   - **anon/public key** : `eyJhbG...` (la clé publique, longue)

## ÉTAPE 5 — Configurer la page HTML (2 min)

1. Ouvre le fichier `filmotheque_supabase.html` (fourni)
2. En haut du JavaScript, remplace les 2 lignes :
   ```
   const SUPABASE_URL = 'https://VOTRE_URL.supabase.co';
   const SUPABASE_KEY = 'VOTRE_CLE_ANON';
   ```
3. Colle tes vraies valeurs de l'étape 4

## ÉTAPE 6 — Héberger la page HTML (2 min)

### Option A : Netlify Drop (le plus simple)
1. Va sur **https://app.netlify.com/drop**
2. Glisse-dépose ton fichier `filmotheque_supabase.html` 
3. Tu obtiens une URL type `https://xxx.netlify.app` → partage-la à tes proches

### Option B : GitHub Pages (gratuit aussi)
1. Crée un repo GitHub, push le fichier HTML
2. Active GitHub Pages dans Settings → Pages

### Option C : Ouvre le fichier localement
- Double-clique sur le fichier HTML → ça marche directement dans ton navigateur

---

## ÉTAPE 7 — Sécurité (optionnel mais recommandé)

Par défaut, l'API Supabase est protégée par **Row Level Security (RLS)**.
Le script SQL fourni active déjà des policies qui permettent :
- **Lecture** : tout le monde (avec la clé anon)
- **Écriture** : tout le monde (avec la clé anon)

Si tu veux restreindre l'accès, tu peux activer l'authentification Supabase
(email/password) — mais pour toi + quelques proches, le mode actuel suffit.

> ⚠️ Ne partage pas ta clé `service_role` (la clé secrète). 
> La clé `anon` est faite pour être dans le code front-end.

---

## Architecture finale

```
┌─────────────────────┐         ┌──────────────────────────┐
│                     │  REST   │                          │
│  filmotheque.html   │ ◄─────► │  Supabase (PostgreSQL)   │
│  (hébergé Netlify)  │  API    │  Plan gratuit            │
│                     │         │                          │
└─────────────────────┘         │  Tables :                │
                                │  ├── films               │
  Tes proches y accèdent        │  ├── genres              │
  via une URL publique          │  ├── directors           │
                                │  ├── actors              │
                                │  ├── posters             │
                                │  ├── film_genres         │
                                │  ├── film_actors         │
                                │  └── film_directors      │
                                └──────────────────────────┘
```

---

## En cas de problème

| Symptôme | Solution |
|----------|----------|
| "No rows returned" après l'import | Va dans Table Editor pour vérifier |
| Page blanche | Vérifie l'URL et la clé dans le HTML (pas d'espace) |
| Erreur 401 | La clé anon est incorrecte ou expirée |
| Films non sauvegardés | Vérifie que RLS est bien configuré (le script le fait) |
| CORS error | Supabase gère le CORS automatiquement, ça devrait marcher |
