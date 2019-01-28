import sys
import os
import argparse
from   jinja2   import Environment, FileSystemLoader, select_autoescape

parser = argparse.ArgumentParser(description='Template all necessary AWS objects')
parser.add_argument('--s3-bucket', dest='bucket', type=str, required=True, help='the S3 bucket which holds your VM image')
parser.add_argument('--image-file', dest='image', type=str, required=True, help='the location of the VM image within the S3 bucket')
args = parser.parse_args()

script_location = os.path.abspath(os.path.dirname(sys.argv[0]))
template_location = os.path.join(script_location, "templates")
template_destination = os.path.join(script_location, "aws_config")

try:
    os.mkdir(template_destination)
except OSError:
    pass

env = Environment(loader=FileSystemLoader(template_location))

containers_template    = env.get_template("containers.json.j2")
containers_render      = containers_template.render(s3_bucket=args.bucket, s3_key=args.image)
containers_destination = os.path.join(template_destination, "containers.json")
with open(containers_destination, "wb") as f:
    f.write(containers_render)

role_template    = env.get_template("role-policy.json.j2")
role_render      = role_template.render(s3_bucket=args.bucket)
role_destination = os.path.join(template_destination, "role-policy.json")
with open(role_destination, "wb") as f:
    f.write(role_render)

trust_template    = env.get_template("trust-policy.json.j2")
trust_render      = trust_template.render()
trust_destination = os.path.join(template_destination, "trust-policy.json")
with open(trust_destination, "wb") as f:
    f.write(trust_render)
