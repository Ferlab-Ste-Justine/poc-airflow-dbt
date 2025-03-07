create table {relation_name} (
    locus_id BIGINT,
    locus VARCHAR(65516),
    interpretations ARRAY<VARCHAR(256)>,
    hash VARCHAR(256)
)