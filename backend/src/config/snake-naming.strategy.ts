import { DefaultNamingStrategy, NamingStrategyInterface } from 'typeorm';

function toSnakeCase(str: string): string {
  return str.replace(/([A-Z])/g, '_$1').toLowerCase().replace(/^_/, '');
}

export class SnakeNamingStrategy extends DefaultNamingStrategy implements NamingStrategyInterface {
  tableName(className: string, customName?: string): string {
    return customName || toSnakeCase(className);
  }

  columnName(propertyName: string, customName?: string, embeddedPrefixes?: string[]): string {
    return customName || toSnakeCase(propertyName);
  }

  relationName(propertyName: string): string {
    return toSnakeCase(propertyName);
  }

  joinColumnName(relationName: string, referencedColumnName: string): string {
    return toSnakeCase(relationName + '_' + referencedColumnName);
  }

  joinTableName(firstTableName: string, secondTableName: string): string {
    return toSnakeCase(firstTableName + '_' + secondTableName);
  }

  joinTableColumnName(tableName: string, propertyName: string, columnName?: string): string {
    return toSnakeCase(tableName + '_' + (columnName || propertyName));
  }
}
