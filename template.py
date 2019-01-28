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

env = Environment(loader=FileSystemLoader(template_location))

containers_template = env.get_template("containers.json.j2")
containers_render   = template.render(s3_bucket=args.bucket, s3_key=args.image)

role_template = env.get_template("role-policy.json.j2")
role_render   = template.render(s3_bucket=args.bucket)

trust_template = env.get_template("trust-policy.json.j2")
trust_render   = template.render(hello_world="this is a test")
