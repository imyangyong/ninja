import { readdir, readFile } from "node:fs/promises";
import { basename, dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const MODULE_DIR = dirname(fileURLToPath(import.meta.url));
const PLUGIN_ROOT = dirname(MODULE_DIR);
const SKILLS_DIR = join(PLUGIN_ROOT, "skills");

function parseSkill(content) {
  const match = content.match(/^---\n([\s\S]*?)\n---\n?/);
  const frontmatter = match?.[1] ?? "";
  const metadata = {};

  for (const line of frontmatter.split("\n")) {
    const field = line.match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
    if (!field) continue;
    metadata[field[1]] = field[2].replace(/^["']|["']$/g, "");
  }

  return metadata;
}

async function listSkills() {
  const entries = await readdir(SKILLS_DIR, { withFileTypes: true });
  const skills = [];

  for (const entry of entries) {
    if (!entry.isDirectory()) continue;
    const skillPath = join(SKILLS_DIR, entry.name, "SKILL.md");
    const content = await readFile(skillPath, "utf8").catch(() => null);
    if (!content) continue;
    const metadata = parseSkill(content);
    skills.push({
      name: metadata.name || entry.name,
      description: metadata.description || "",
      path: skillPath,
    });
  }

  return skills.sort((a, b) => a.name.localeCompare(b.name));
}

async function readSkill(name) {
  const skills = await listSkills();
  const skill = skills.find((item) => item.name === name || basename(dirname(item.path)) === name);
  if (!skill) {
    const available = skills.map((item) => item.name).join(", ") || "(none)";
    throw new Error(`Unknown ninja skill "${name}". Available skills: ${available}`);
  }

  return readFile(skill.path, "utf8");
}

function matchDangerousCommand(command) {
  const rules = [];
  const match = (pattern) => pattern.test(command);
  const boundary = "(^|[\\s;|&`])";

  if (match(new RegExp(`${boundary}rm\\s`, "i"))) rules.push("rm (delete files/directories)");
  if (match(/\bDELETE\s+FROM\b/i)) rules.push("DELETE FROM (SQL delete)");
  if (match(/\bDROP\s+(TABLE|DATABASE|SCHEMA)\b/i)) rules.push("DROP TABLE/DATABASE (SQL destructive)");
  if (match(/\bTRUNCATE\s+(TABLE\s+)?\S/i)) rules.push("TRUNCATE (SQL/file clearing)");
  if (match(new RegExp(`${boundary}(shutdown|reboot|poweroff|halt)\\b`, "i"))) {
    rules.push("shutdown/reboot/poweroff/halt (system power action)");
  }
  if (match(new RegExp(`${boundary}(mkfs|fdisk)\\b`, "i"))) rules.push("mkfs/fdisk (disk formatting)");
  if (match(/\bdiskutil\b.*(erase|format)/i)) rules.push("diskutil erase/format (disk formatting)");
  if (match(/\bdd\b.*\bof=\/dev\//i)) rules.push("dd of=/dev/... (direct disk write)");
  if (match(/(curl|wget)\b.+\|\s*(bash|sh|zsh|python|python3|node)\b/i)) {
    rules.push("curl/wget | shell (remote code execution)");
  }
  if (match(/git\s+push\b/i) && match(/(--force|-f)\b/i) && match(/\b(main|master)\b/i)) {
    rules.push("git push --force to main/master");
  }

  return rules;
}

export function createNinjaPlugin(tool) {
  return async function NinjaOpenCodePlugin() {
    return {
      tool: {
        ninja_skill: tool({
          description:
            "List or read skills bundled inside the local ninja plugin without copying them into global skill directories.",
          args: {
            action: tool.schema.enum(["list", "read"]).default("list").describe("Whether to list skills or read one skill."),
            name: tool.schema.string().optional().describe("Skill name to read when action is read."),
          },
          async execute(args) {
            if (args.action === "read") {
              if (!args.name) throw new Error('The "name" argument is required when action is "read".');
              return {
                title: `ninja skill: ${args.name}`,
                output: await readSkill(args.name),
              };
            }

            const skills = await listSkills();
            const output = skills.map((skill) => `- ${skill.name}: ${skill.description}`).join("\n");
            return {
              title: "ninja bundled skills",
              output: output || "No ninja skills found.",
              metadata: { pluginRoot: PLUGIN_ROOT, skillCount: skills.length },
            };
          },
        }),
      },

      "tool.execute.before": async (input, output) => {
        if (input.tool !== "bash") return;
        const command = output.args?.command;
        if (typeof command !== "string" || command.length === 0) return;

        const rules = matchDangerousCommand(command);
        if (rules.length === 0) return;

        throw new Error(
          [
            "Ninja blocked a dangerous bash command.",
            "Matched rules:",
            ...rules.map((rule) => `- ${rule}`),
            `Command: ${command}`,
            "Run it manually in a trusted terminal if you really intend to execute it.",
          ].join("\n"),
        );
      },
    };
  };
}
