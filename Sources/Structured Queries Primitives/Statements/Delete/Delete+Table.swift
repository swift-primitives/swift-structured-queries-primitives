extension Table {

    public static func delete() -> DeleteOf<Self> {
        Where().delete()
    }
}
