extension Where {

    public func delete() -> DeleteOf<From> {
        Delete(
            isEmpty: scope == .empty,
            where: scope == .unscoped ? predicates : From.all._selectClauses.where + predicates
        )
    }

    public func update(
        set updates: (inout Updates<From>) -> Void
    ) -> UpdateOf<From> {
        Update(
            isEmpty: scope == .empty,
            updates: Updates(updates),
            where: scope == .unscoped ? predicates : From.all._selectClauses.where + predicates
        )
    }
}
