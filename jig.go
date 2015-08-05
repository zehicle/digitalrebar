package crowbar

import (
	"errors"
	"log"
	"strconv"
)

// Jigs use Hammers to perform (hopefully) idempotent actions on Nodes
// on behalf of Roles through NodeRoles.
type Jig struct {
	ID             int64  `json:"id,omitempty"`
	Name           string `json:"name,omitempty"`
	Description    string `json:"description,omitempty"`
	Active         bool   `json:"active,omitempty"`
	ClientRoleName string `json:"client_role_name,omitempty"`
	Server         string `json:"server,omitempty"`
	ClientName     string `json:"client_name,omitempty"`
	Key            string `json:"key,omitempty"`
	CreatedAt      string `json:"created_at,omitempty"`
	UpdatedAt      string `json:"updated_at,omitempty"`
	lastJson       []byte
}

func (o *Jig) Id() string {
	if o.ID != 0 {
		return strconv.FormatInt(o.ID, 10)
	} else if o.Name != "" {
		return o.Name
	} else {
		log.Panic("Jig has no ID or name")
		return ""
	}
}

func (o *Jig) SetId(s string) error {
	if o.ID != 0 || o.Name != "" {
		return errors.New("SetId can only be used on an un-IDed object")
	}
	if id, err := strconv.ParseInt(s, 10, 64); err == nil {
		o.ID = id
	} else {
		o.Name = s
	}
	return nil
}

func (o *Jig) ApiName() string {
	return "jigs"
}

func (o *Jig) Match() (res []*Jig, err error) {
	res = make([]*Jig, 0)
	return res, session.match(o, &res, o.ApiName(), "match")
}

func (o *Jig) setLastJSON(b []byte) {
	o.lastJson = make([]byte, len(b))
	copy(o.lastJson, b)
}

func (o *Jig) lastJSON() []byte {
	return o.lastJson
}

type Jigger interface {
	Crudder
	jigs()
}

// Jigs returns all of the Jigs.
func Jigs(scope ...Jigger) (res []*Jig, err error) {
	res = make([]*Jig, 0)
	paths := make([]string, len(scope))
	for i := range scope {
		paths[i] = url(scope[i])
	}

	return res, session.list(&res, append(paths, "jigs")...)
}
