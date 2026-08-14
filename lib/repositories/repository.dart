abstract class Repository<T> {
  Future<List<T>> findAll();
  Future<T?> findById(String id);
  Future<void> save(T entity);
  Future<void> delete(String id);
  Future<void> deleteAll();
}