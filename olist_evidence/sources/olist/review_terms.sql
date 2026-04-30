select
    term,
    tfidf_score,
    frequency,
    rank
from main.review_term_frequencies
where rank <= 30
order by rank