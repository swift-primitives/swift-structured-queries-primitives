extension Table {

    public static func update(
        set updates: (inout Updates<Self>) -> Void
    ) -> UpdateOf<Self> {
        Where().update(set: updates)
    }
}
