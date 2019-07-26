use plasma_db::impls::kvs::CoreDbLevelDbImpl;
use plasma_db::traits::kvs::{BaseDbKey, Bucket, KeyValueStore};
use plasma_db::traits::db::DatabaseTrait;

pub struct Layer2Core {
    db: CoreDbLevelDbImpl,
}

impl Default for Layer2Core {
    fn default() -> Self {
        Layer2Core {
            db: CoreDbLevelDbImpl::open("test"),
        }
    }
}

impl Layer2Core {
    /// Gets a bucket.
    ///     Bucket enables not only storing data but also share data eith other clients.
    pub fn bucket(&self, prefix: &str) -> Bucket {
        self.db.bucket(&BaseDbKey::from(prefix.as_bytes()))
    }
}
