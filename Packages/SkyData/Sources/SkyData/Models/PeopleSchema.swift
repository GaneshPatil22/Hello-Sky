import Foundation
import SwiftData

/// The first shipped shape of the people store.
public enum PeopleSchemaV1: VersionedSchema {
    public static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }
    public static var models: [any PersistentModel.Type] { [StoredPerson.self] }
}

/// How the store moves between schema versions.
///
/// There is one version so far, so there are no stages. The plan exists now so
/// that adding v2's photo avatars is a migration rather than a rewrite.
public enum PeopleMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] { [PeopleSchemaV1.self] }
    public static var stages: [MigrationStage] { [] }
}
