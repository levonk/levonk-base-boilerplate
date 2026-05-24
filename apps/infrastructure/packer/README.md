# Packer Boilerplate (Copier)

Scaffolds a Packer image build project with multiple builder support.

## Usage

```bash
copier copy ./boilerplate/apps/infrastructure/packer ./out/my-image
```

## Generated Structure

```
my-packer-project/
  sources.pkr.hcl
  variables.pkr.hcl
  build.pkr.hcl
  templates/
    user-data.pkrtpl.hcl
```

## Inputs

- `project_name`: Project name
- `image_name`: Output image name
- `builder`: Builder type (qemu, docker, amazon-ebs, vsphere-iso)
- `author_name`, `author_email`: Author info
