# Export and Migration Scripts
A collection of scripts for performing actions in the following scenarios:
- Migrating components/configuration to another instance
- Keeping components in sync between SQL AlwaysOn Replicas
- Export for backup purposes

## ExportAgentJobs.ps1
A script to export SQL Agent Jobs to .sql files

```
.\ExportAgentJobs.ps1 -SqlServer Svr2016 -Path C:\SQLExports
```


# License
All code is provided "as is" as per the [MIT License](https://github.com/Microsoft/DataInsightsAsia/blob/master/LICENSE).
