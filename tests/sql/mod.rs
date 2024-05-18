mod expression;
mod mutation;
mod query;
mod schema;

use tootdb::error::Result;
use tootdb::sql::engine::{Engine, KV};
use tootdb::storage::kv;

/// Sets up a basic in-memory SQL engine with an initial dataset.
fn setup(queries: Vec<&str>) -> Result<KV> {
    let engine = KV::new(kv::MVCC::new(Box::new(kv::Memory::new())));
    let mut session = engine.session()?;
    session.execute("BEGIN")?;
    for query in queries {
        session.execute(query)?;
    }
    session.execute("COMMIT")?;
    Ok(engine)
}
