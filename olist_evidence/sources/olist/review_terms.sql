select
    term,
    tfidf_score,
    frequency,
    rank
from main.review_term_frequencies
where rank <= 20
order by rank