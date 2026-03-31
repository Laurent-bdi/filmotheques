-- ═══════════════════════════════════════════════════════════
-- FILMOTHÈQUE — Supabase Migration (étape 2)
-- Copier-coller dans SQL Editor → Run
-- ═══════════════════════════════════════════════════════════

-- Tables de référence
CREATE TABLE genres (
    id   TEXT PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE directors (
    id   TEXT PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE actors (
    id   TEXT PRIMARY KEY,
    name TEXT NOT NULL
);

-- Table principale
CREATE TABLE films (
    id         TEXT PRIMARY KEY,
    title      TEXT NOT NULL,
    fr_title   TEXT,
    year       TEXT,
    overview   TEXT,
    seen       BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Affiches
CREATE TABLE posters (
    film_id TEXT PRIMARY KEY REFERENCES films(id) ON DELETE CASCADE,
    url     TEXT NOT NULL
);

-- Relations N:N
CREATE TABLE film_genres (
    film_id  TEXT REFERENCES films(id) ON DELETE CASCADE,
    genre_id TEXT REFERENCES genres(id) ON DELETE CASCADE,
    PRIMARY KEY (film_id, genre_id)
);

CREATE TABLE film_actors (
    film_id    TEXT REFERENCES films(id) ON DELETE CASCADE,
    actor_id   TEXT REFERENCES actors(id) ON DELETE CASCADE,
    cast_order INTEGER DEFAULT 0,
    PRIMARY KEY (film_id, actor_id)
);

CREATE TABLE film_directors (
    film_id     TEXT REFERENCES films(id) ON DELETE CASCADE,
    director_id TEXT REFERENCES directors(id) ON DELETE CASCADE,
    PRIMARY KEY (film_id, director_id)
);

-- Index pour les performances
CREATE INDEX idx_films_year ON films(year);
CREATE INDEX idx_films_seen ON films(seen);
CREATE INDEX idx_fg_genre ON film_genres(genre_id);
CREATE INDEX idx_fa_actor ON film_actors(actor_id);
CREATE INDEX idx_fd_director ON film_directors(director_id);

-- Row Level Security : autoriser lecture et écriture publiques (clé anon)
ALTER TABLE films ENABLE ROW LEVEL SECURITY;
ALTER TABLE genres ENABLE ROW LEVEL SECURITY;
ALTER TABLE directors ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors ENABLE ROW LEVEL SECURITY;
ALTER TABLE posters ENABLE ROW LEVEL SECURITY;
ALTER TABLE film_genres ENABLE ROW LEVEL SECURITY;
ALTER TABLE film_actors ENABLE ROW LEVEL SECURITY;
ALTER TABLE film_directors ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read"  ON films FOR SELECT USING (true);
CREATE POLICY "Public write" ON films FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Public read"  ON genres FOR SELECT USING (true);
CREATE POLICY "Public write" ON genres FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Public read"  ON directors FOR SELECT USING (true);
CREATE POLICY "Public write" ON directors FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Public read"  ON actors FOR SELECT USING (true);
CREATE POLICY "Public write" ON actors FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Public read"  ON posters FOR SELECT USING (true);
CREATE POLICY "Public write" ON posters FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Public read"  ON film_genres FOR SELECT USING (true);
CREATE POLICY "Public write" ON film_genres FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Public read"  ON film_actors FOR SELECT USING (true);
CREATE POLICY "Public write" ON film_actors FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Public read"  ON film_directors FOR SELECT USING (true);
CREATE POLICY "Public write" ON film_directors FOR ALL USING (true) WITH CHECK (true);

-- Vue pratique : film complet avec jointures
CREATE OR REPLACE VIEW v_films_complets AS
SELECT 
    f.id,
    f.title,
    f.fr_title,
    f.year,
    f.overview,
    f.seen,
    f.created_at,
    p.url AS poster_url,
    (SELECT d.name FROM film_directors fd JOIN directors d ON d.id = fd.director_id WHERE fd.film_id = f.id LIMIT 1) AS director_name,
    ARRAY(SELECT g.name FROM film_genres fg JOIN genres g ON g.id = fg.genre_id WHERE fg.film_id = f.id ORDER BY g.name) AS genres,
    ARRAY(SELECT a.name FROM film_actors fa JOIN actors a ON a.id = fa.actor_id WHERE fa.film_id = f.id ORDER BY fa.cast_order) AS actors
FROM films f
LEFT JOIN posters p ON p.film_id = f.id;
