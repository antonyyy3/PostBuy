PRAGMA foreign_keys = ON;

BEGIN;

CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL CHECK (length(trim(name)) > 0),
    email TEXT NOT NULL COLLATE NOCASE UNIQUE CHECK (length(trim(email)) > 0),
    password_hash TEXT NOT NULL CHECK (length(password_hash) > 0),
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
) STRICT;

CREATE TABLE IF NOT EXISTS listings (
    id INTEGER PRIMARY KEY,
    seller_id INTEGER NOT NULL REFERENCES users (id),
    title TEXT NOT NULL CHECK (length(trim(title)) > 0),
    description TEXT NOT NULL CHECK (length(trim(description)) > 0),
    price_minor INTEGER NOT NULL CHECK (price_minor > 0),
    status TEXT NOT NULL DEFAULT 'available'
        CHECK (status IN ('available', 'reserved', 'sold')),
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
) STRICT;

CREATE TABLE IF NOT EXISTS orders (
    id INTEGER PRIMARY KEY,
    listing_id INTEGER NOT NULL UNIQUE REFERENCES listings (id),
    buyer_id INTEGER NOT NULL REFERENCES users (id),
    price_minor INTEGER NOT NULL CHECK (price_minor > 0),
    status TEXT NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'confirmed')),
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    confirmed_at TEXT,
    CHECK (
        (status = 'pending' AND confirmed_at IS NULL)
        OR (status = 'confirmed' AND confirmed_at IS NOT NULL)
    )
) STRICT;

CREATE INDEX IF NOT EXISTS listings_by_seller ON listings (seller_id);
CREATE INDEX IF NOT EXISTS listings_by_status ON listings (status);
CREATE INDEX IF NOT EXISTS orders_by_buyer ON orders (buyer_id);

COMMIT;
