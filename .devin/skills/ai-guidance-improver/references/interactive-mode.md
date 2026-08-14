# Interactive Mode Workflow

When operating in interactive mode (real-time prompt improvement), follow this streamlined process:

## Step 1: Analyze the Prompt

Analyze the provided prompt text for common issues:

**Clarity Issues:**
- Ambiguous instructions or requirements
- Missing context or constraints
- Unclear success criteria
- Vague terminology

**Structure Issues:**
- Poor organization of information
- Missing key sections (context, requirements, output format)
- Inconsistent formatting
- Hard to scan or understand

**Efficiency Issues:**
- Redundant information
- Unnecessary explanations
- Verbose descriptions
- Could be more concise

**Completeness Issues:**
- Missing edge case handling
- No error handling guidance
- Unclear boundaries
- Missing validation criteria

## Step 2: Provide Immediate Suggestions

Offer specific, actionable improvements:

**For clarity issues:**
- "Consider adding: [specific context]"
- "Clarify: [ambiguous phrase]"
- "Specify: [missing requirement]"

**For structure issues:**
- "Suggest reorganizing as: [proposed structure]"
- "Add section: [missing section]"
- "Format as: [suggested format]"

**For efficiency issues:**
- "This could be shortened to: [concise version]"
- "Remove redundant: [specific text]"
- "Combine: [related points]"

**For completeness issues:**
- "Add handling for: [edge case]"
- "Specify error behavior: [guidance]"
- "Define boundaries: [constraints]"

## Step 3: Offer Improvements

Provide concrete improvements with explanations:

**Format suggestions as:**
```
**Original:** [original text]
**Improved:** [improved text]
**Reason:** [why this is better]
```

**Prioritize suggestions:**
1. **Critical** - Issues that would cause confusion or failure
2. **Important** - Issues that affect quality or efficiency
3. **Nice to have** - Minor improvements or polish

## Step 4: Iterate

Allow the user to:
- Accept specific suggestions
- Request alternative improvements
- Ask for clarification on suggestions
- Provide additional context for refinement

**Example interaction:**

**User:** "improve this prompt: Write a function that sorts data"

**AI:** Here are suggestions to improve your prompt:

**Critical improvements:**
- **Original:** "Write a function that sorts data"
- **Improved:** "Write a function that sorts an array of integers in ascending order using quicksort algorithm"
- **Reason:** Specifies data type, sort direction, and algorithm for unambiguous implementation

**Important improvements:**
- **Original:** [no error handling mentioned]
- **Improved:** "Handle edge cases: empty arrays, single elements, and duplicate values"
- **Reason:** Defines behavior for common edge cases

**Nice to have:**
- **Original:** [no performance requirements]
- **Improved:** "Optimize for O(n log n) time complexity and O(log n) space complexity"
- **Reason:** Sets clear performance expectations

Would you like me to apply these suggestions, or would you prefer different improvements?

## Step 5: Finalize

When the user is satisfied:
- Provide the final improved prompt
- Explain the key improvements made
- Note any remaining trade-offs or considerations
- Suggest testing or validation if appropriate
