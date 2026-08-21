extension Select {

    public func window<each J: Table>(
        _ name: String,
        _ builder:
            @escaping (WindowSpec, From.TableColumns, repeat (each J).TableColumns) -> WindowSpec
    ) -> Self
    where Joins == (repeat each J) {
        let spec = builder(WindowSpec(), From.columns, repeat (each J).columns)
        let specification = spec.generateSpecificationFragment()

        var select = self
        select.windows.append((name: name, specification: specification))
        return select
    }

    public func window(
        _ name: String,
        _ builder: @escaping (WindowSpec, From.TableColumns) -> WindowSpec
    ) -> Self
    where Joins == () {
        let spec = builder(WindowSpec(), From.columns)
        let specification = spec.generateSpecificationFragment()

        var select = self
        select.windows.append((name: name, specification: specification))
        return select
    }
}

extension Table {

    public static func window(
        _ name: String,
        _ builder: @escaping (WindowSpec, TableColumns) -> WindowSpec
    ) -> SelectOf<Self> {
        Where().window(name, builder)
    }
}

extension Where {

    public func window(
        _ name: String,
        _ builder: @escaping (WindowSpec, From.TableColumns) -> WindowSpec
    ) -> SelectOf<From> {
        asSelect().window(name, builder)
    }
}
